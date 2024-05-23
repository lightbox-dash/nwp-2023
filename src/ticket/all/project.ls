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

  utils: {disabled, filtered}
  view:
    key: -> it.slug
    list: ~> filtered!
    view:
      init: "@": ({node, ctx}) ~> @pn.set ctx, node
      action:
        click:
          "custom-id": ({node, ctx}) ~>
            v = @lib.idx(prj: ctx)
            @active["custom-id"] = if @active["custom-id"] == v => null else v
            @render!
          name: ({node, ctx, evt}) ~>
            def = if def = @judge.{}form.{}config.prjdef => "/v/#def" else ""
            url = "/prj/#{ctx.slug}#def/embed"
            # if we want to enable inline viewing:
            #@view.get("iframe").setAttribute \src, "/prj/#{ctx.slug}#def/embed"
            #@view.get("iframe-placeholder").classList.add \d-none
            window.open url
          avoid: @tool.avoid.view
      handler:
        "show-group": ({node}) ~> node.classList.toggle \d-none, !((@data.cfg or {}).group or {}).enabled
        "group": ({node, ctx}) ~>
          node.textContent = t("_local:#{@get-group(prj: ctx).info.name or 'n/a'}")
        "@": ({node, ctx}) ~>
          node.classList.toggle \highlight, !!@pm.get(ctx).matched
          node.classList.toggle \lockdown, (
            @active.order == @pm.get(ctx).order or @active["custom-id"] == @lib.idx(prj: ctx)
          )
          is-disabled = disabled(ctx)
          should-hide = (@data.cfg or {})["hide-disabled"]
          group-cfg = ((@data.cfg or {}).group or {})
          group-show = ((group-cfg.entry or {})[ctx.grp] or {}).show
          should-hide-grp = !!(group-cfg.enabled and (group-show? and !group-show))
          node.classList.toggle \disabled, (is-disabled or should-hide-grp)
          node.classList.toggle \hidden, ((is-disabled and should-hide) or should-hide-grp)
        "custom-id": ({node, ctx}) ~>
          node.classList.toggle \font-weight-bold, @active["custom-id"] == @lib.idx(prj: ctx)
          node.innerText = @lib.idx(prj: ctx)
        idx: ({node, ctx}) ~> node.innerText = (@pm.get(ctx).order + 1)
        rank:
          handler: "@": ({node, ctxs}) ~>
            node.classList.toggle \font-weight-bold, @active.order == @pm.get(ctxs.0).order
          action: click: "@": ({ctxs}) ~>
            v = @pm.get(ctxs.0).order
            # we use order since there may be multiple ranks
            @active.order = if @active.order == v => null else v
            @render!
          text:
            number: ({ctxs}) ~> @pm.get(ctxs.0).rank
            postfix: ({ctxs}) ~>
              v = @pm.get(ctxs.0).rank
              if "#v".endsWith(\1) => \st
              else if "#v".endsWith(\2) => \nd
              else if "#v".endsWith(\3) => \rd
              else \th
        judge:
          list: ~> @judge.users
          key: -> it.key
          view:
            handler: "ticket": ({node, ctx, ctxs}) ~>
              v = ((@data.user or {})[ctx.key].prj or {})[ctxs.0.key].v or 0
              node.innerText = v
              node.classList.toggle \highlight, !!v
        result: ({node, ctx}) ~>
          node.classList.toggle \accept, false
          node.classList.toggle \reject, false
          node.style.background = ''
          node.style.color = ''
          icon = node.querySelector('[ld=icon]')

          result = @result-mark {prj: ctx}
          vm = @vote-method!
          stat = @pm.get(ctx)
          if vm == \t or true =>
            ret = result.picked
            node.classList.toggle \accept, ret
            node.classList.toggle \reject, !ret
            icon.setAttribute \class, "i-radiobox-off"

          node.classList.toggle \overflow, result.overflow
          node.classList.toggle \manual, !result.overflow

        /*progress:
          list: ~> @options.list!
          key: -> it.name
          view: handler: "@": ({node, ctx, ctxs}) ~>
            o = @pm.get ctxs.0
            percent = 0
            #percent = 100 * o.count[ctx.key] / o.total
            node.style <<< background: ctx.color, width: "#{percent}%"
        */

        "staff-note":
          init: "@": ({node, local}) -> local.type = node.getAttribute(\data-type) or \note
          action: click:
            "@": ({node, ctxs, local}) ~>
              @tool["staff-note"].view {prj: ctxs.0, type: local.type}
          handler:
            "@": ({node, ctxs, local}) ~>
              p = ctxs.0
              note = @data.prj{}[p.key][local.type]
              node.classList.toggle \text-secondary, !note
              node.classList.toggle \text-primary, !!note
            icon: ({node, ctxs, local}) ~>
              p = ctxs.0
              note = @data.prj{}[p.key][local.type]
              node.classList.toggle \i-comment, !note
              node.classList.toggle \i-discuss, !!note

      text:
        name: ({node, ctx}) ~> @lib.info(prj: ctx).name or t('unnamed')
        teamname: ({ctx}) ~> @lib.info(prj: ctx).team.name or t('unnamed')
        #rate: ({ctx}) ~> "#{(100 * @pm.get(ctx).rate or 0).toFixed(2)}%"
        ticket: ({ctx}) ~> @pm.get(ctx).ticket or 0
        avoid: ({ctx}) ~>
          @judge.users
            .filter (j) ~> @data.user{}[j.key].{}prj{}[ctx.key].avoid
            .length

