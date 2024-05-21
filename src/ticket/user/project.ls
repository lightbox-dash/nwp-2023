submod.project = ({ctx, t}) ->
  {ldcolor} = ctx
  disabled = (prj) ~>
    cfg = @data.cfg or {}
    if !cfg["custom-order"] => return false
    !!((cfg.orders or {})[prj.key] or {}).disabled
  filtered = (opt={})~>
    co = (@data.cfg or {})["custom-order"]
    hd = (@data.cfg or {})["hide-disabled"] or opt.hide
    gr = (@data.cfg or {}).group or {}
    ge = gr.entry or {}
    @prjs.filter (p) ~>
      if gr.enabled and (ge[p.grp] or {}).show? and !ge[p.grp].show => return false
      !co or !disabled(p) or !hd
  get-ticket = ({prj}) ~>
    if !!@datum.prj{}[prj.key].avoid => return 0
    return @datum.prj[prj.key].v or 0
  set-ticket = ({prj, ticket, offset}) ~>
    if !!@datum.prj{}[prj.key].avoid => return
    if disabled(prj) => return
    max-ticket = @max-ticket!
    point-quota = @point-quota!
    pt-ratio = @pt-ratio!
    used-point = @datum["used-point"] or 0
    cur-ticket = @datum.prj[prj.key].v or 0
    if ticket? and cur-ticket == ticket => return
    new-ticket = if ticket? => ticket else cur-ticket + offset >? 0 <? max-ticket
    [new-point,cur-point] = if pt-ratio == \quad => [new-ticket ** 2, cur-ticket ** 2]
    else [new-ticket, cur-ticket]
    ticket = new-ticket
    original-ticket = new-ticket
    if used-point - cur-point + new-point > point-quota => 
      remains = point-quota - (used-point + cur-point) >? 0
      ticket = (if pt-ratio == \quad => Math.floor(Math.sqrt(remains)) else remains) <? max-ticket
      new-point = ticket ** 2
    if ticket != original-ticket and ticket == 0 => return ldnotify.send \warning, t("已耗盡點數配額")
    @datum.prj[prj.key].v = ticket
    sum = 0
    overflow = false
    for k,v of @datum.prj =>
      pt = (v or {}).v
      spend = if pt-ratio == \quad => (pt or 0) ** 2 else (pt or 0)
      if sum + spend <= point-quota => sum += spend
      else
        v.v = 0
        overflow = true
    @datum["used-point"] = sum
    if overflow => ldnotify.send \warning, t("點數配額超支，已刪除超出部份。請檢查給分")
    @update!
    @render!

  obj = {}
  view =
    list: ~> filtered!
    key: -> it.slug
    view:
      init: "@": ({node, ctx}) ~> @pn.set ctx, node
      action: click:
        "ticket-set": ({ctx, node, evt}) ->
          v = +node.getAttribute(\data-value)
          set-ticket {prj: ctx, ticket: v}
        "ticket-adjust": ({ctx, node, evt}) ->
          dir = +node.getAttribute(\data-dir)
          set-ticket {prj: ctx, offset: dir}
        "ticket-cell": ({ctx, node, evt}) ~>
          box = node.getBoundingClientRect!
          t = Math.round(((evt.clientX - box.x) / box.width) * @max-ticket!)
          set-ticket {prj: ctx, ticket: t}
        name: ({node, ctx, views}) ~>
          obj.prj = ctx
          def = if def = @judge.{}form.{}config.prjdef => "/v/#def" else ""
          url = "/prj/#{ctx.slug}#def/embed"
          if getComputedStyle(views.1.get(\project-viewer)).display == \none =>
            views.1.render!
            return window.open url
          views.1.get("iframe").setAttribute \src, url
          views.1.get("iframe-placeholder").classList.add \d-none
          views.1.render!
      text:
        name: ({ctx}) ~>
          avoid = (if @datum.prj{}[ctx.key].avoid => (t("avoided") + ' ') else '')
          name = @lib.info(prj: ctx).name or t('unnamed')
          return "#avoid#name"
        teamname: ({ctx}) ~> @lib.info(prj: ctx).team.name or t('unnamed')
        "custom-id": ({node, ctx}) ~> node.innerText = @lib.idx prj: ctx
        key: ({ctx}) -> ctx.key or ''
      handler:
        "ticket-cell": ({ctx, node}) ~>
          v = get-ticket {prj: ctx}
          v1 = (100 * (v / @max-ticket!))
          v2 = v1 + 0.01
          [v1,v2] = [v1,v2].map -> (it).toFixed(2) + "%"
          [fg,bg] = [\currentColor, "rgba(0,0,0,0)"]
          node.style.backgroundImage = """
          linear-gradient(90deg,#fg 0%,#fg #v1,#bg #v2,#bg 100%)
          """
        "ticket-cell-text": ({ctx, node}) ->
          v = get-ticket {prj: ctx}
          node.innerText = if v? and v => v else ''
        "show-group": ({node}) ~> node.classList.toggle \d-none, !((@data.cfg or {}).group or {}).enabled
        group: ({node, ctx}) ~>
          node.textContent = t("_local:#{@get-group(prj: ctx).info.name or 'n/a'}")
        "staff-note":
          handler: "@": ({node, ctxs}) ~>
            d = (@data.prj or {})[ctxs.0.key] or {}
            node.classList.toggle \d-none, !(d.note or d.prenote)
          action: click: "@": ({ctxs}) ~>
            d = (@data.prj or {})[ctxs.0.key] or {}
            if !(d.note or d.prenote) => return
            @tool["staff-note"].view {prj: ctxs.0, mode: 'view'}
        comment:
          handler: icon: ({node, ctxs}) ~>
            has-comment = !!@datum.prj{}[ctxs.0.key].comment
            <[text-primary i-check]>.map -> node.classList.toggle it, has-comment
            <[text-danger i-pen]>.map -> node.classList.toggle it, !has-comment
          action: click: "@": ({ctx, ctxs}) ~>
            if !!@datum.prj{}[ctxs.0.key].avoid => return
            if disabled(ctxs.0) => return
            # admin may also write comments. use `@user` instead of `@judge.cur` here.
            @tool.comment.view {prj: ctxs.0, judge: null, user: @user}
        "@": ({node, local, ctx}) ~>
          node.classList.toggle \avoid, !!@datum.prj{}[ctx.key].avoid
          node.classList.toggle \highlight, !!@pm.get(ctx).matched
          node.classList.toggle \active, obj.prj == ctx
          is-disabled = disabled(ctx)
          should-hide = (@data.cfg or {})["hide-disabled"]
          group-cfg = ((@data.cfg or {}).group or {})
          group-show = ((group-cfg.entry or {})[ctx.grp] or {}).show
          should-hide-grp = !!(group-cfg.enabled and (group-show? and !group-show))
          node.classList.toggle \disabled, (is-disabled or should-hide-grp)
          node.classList.toggle \hidden, ((is-disabled and should-hide) or should-hide-grp)

  return {obj, view, utils: {disabled, filtered}}
