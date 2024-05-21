module.exports =
  pkg:
    name: '@grantdash/judge', path: 'ticket/user.html'
    extend: {name: '@grantdash/judge', path: 'common'}
    dependencies: [
      {name: "ldcolor"}
      {name: "@loadingio/ldcolorpicker"}
      {name: "@loadingio/ldcolorpicker", type: \css, global: true}
    ]
  render: ->
    @sort-prjs!
    @progress.update!
    @view.render!
  init: ({root, ctx, manager, pubsub, t}) ->
    {ldcolor} = ctx
    ({core}) <~ servebase.corectx _
    @ldcvmgr = core.ldcvmgr
    @type = \user
    pubsub.fire \init, {mod: @, submod, ctx}
    @point-quota = -> if !(r = ((@data.cfg or {}).rule or {})["point-quota"]) or isNaN(r) => 1 else r
    @max-ticket = -> if !(r = ((@data.cfg or {}).rule or {})["max-ticket"]) or isNaN(r) => 1 else r
    @pt-ratio = -> if !(r = ((@data.cfg or {}).rule or {})["pt-ratio"]) => \linear else r
    @ticket-reset = ->
      (ret) <~ @ldcv["point-reset-confirm"].get!then _
      if !ret => return
      for k,v of (@datum.prj or {}) => v.v = 0
      @datum["used-point"] = sum
      @update!; @render!

    @progress =
      update: -> @_ = @_get!
      get: -> if !@_ => @_ = @_get! else @_
      _get: ~>
        ret =
          point: {}
          total: 1
          "pending-comment": 0
        if !@prjs => return ret
        filtered-prjs = @submod.project.utils.filtered(hide:true).filter (p) ~> !(@datum.prj[p.key] or {}).avoid
        filtered-prjs.map (p) ~> if !(@datum.prj[p.key] or {}).comment => ret["pending-comment"]++
        ret.total = filtered-prjs.length or 1
        ret.done = filtered-prjs.filter((p) ~> (v = (@datum.prj[p.key] or {}).v)? and v > 0).length
        ret.todo = ret.total - ret.done
        ret.point.total = @point-quota!
        ret.point.used = @datum["used-point"] or 0
        ret.point.available = ret.point.total - ret.point.used
        ret
    @view = new ldview do
      root: root
      init-render: false
      init: ldcv: @tool.ldcv.view
      action:
        click:
          "toggle-rule-description": ({node}) ~> @ldcv["rule-description"].toggle!
          "reset-point": ({node}) ~> @ticket-reset!
          jump: ({node}) ~>
            name = node.getAttribute \data-name
            prjs = @submod.project.utils.filtered!filter (p) ~> !@datum.prj{}[p.key].avoid
            p = if name == \comment => prjs.filter((p) ~> !@datum.prj[p.key].comment).0
            else prjs.filter((p) ~> !@pm.get(p).done).0
            if !p or !(n = @pn.get(p)) => return
            @pn.get(p).scrollIntoView behavior: \smooth, block: \center
      text:
        count: ({node}) ~> @progress.get![node.getAttribute(\data-name)] or 0
        point: ({node}) ~> @progress.get!point.[node.getAttribute(\data-name)] or 0
        "pt-ratio-name": ~>
          n = ((@data.cfg or {}).rule or {})["pt-ratio"]
          if n == \quad => \平方投票法 else \線性投票法
        "point-quota": ({node}) ~> ((@data.cfg or {}).rule or {})["point-quota"] or 1
      handler:
        "used-pt-ratio": ({node}) ~>
          name = node.getAttribute \data-name
          ratio = ((@data.cfg or {}).rule or {})["pt-ratio"]
          node.classList.toggle \d-none, ratio != name
        "comment-required": ({node}) ~>
          hide = !!((@data.cfg or {}).rule or {})["comment-optional"]
          node.classList.toggle \d-none, hide
        "show-group": ({node}) ~> node.classList.toggle \d-none, !((@data.cfg or {}).group or {}).enabled
        project: @submod.project.view
        "search-widget": @tool.search.view
        "progress-point": ({node}) ~>
          p = @progress.get!
          node.style.width = "#{100 * p.point.used / p.point.total}%"
        "progress-percent": ({node, names}) ~>
          p = @progress.get!
          node.innerText = Math.round(100 * p.done / (p.total or 1))
