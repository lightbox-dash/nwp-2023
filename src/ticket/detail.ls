module.exports =
  pkg:
    i18n:
      en:
        "編號": "No."
        "提案名稱": "Project Name"
        "給分": "Score"
        "票數": "Ticket"
        "委員": "Panelist"
        "列印此表": "Print this form"
        "評註": "Comment"
        "建議": "Advice"
        "尚未設定任何評審": "No Judge Configured"
        "更換排版方式": "Change Layout"
        "評審為中心": "Judge Based"
        "案件為中心": "Project Based"
        "總表": "Overview"
        "案件名稱": "Project Name"
        "單位名": "Team Name"
        "序位": "Rank"
      "zh-TW":
        "編號": "編號"
        "提案名稱": "提案名稱"
        "給分": "給分"
        "票數": "票數"
        "委員": "委員"
        "列印此表": "列印此表"
        "評註": "評註"
        "建議": "建議"
        "尚未設定任何評審": "尚未設定任何評審"
        "更換排版方式": "更換排版方式"
        "評審為中心": "評審為中心"
        "案件為中心": "案件為中心"
        "總表": "總表"
        "案件名稱": "案件名稱"
        "單位名": "單位名"
        "序位": "序位"
  interface: -> @ldcv
  init: ({root, ctx, manager}) ->
    @host = {}
    @ldcv = new ldcover root: root
    @pivot = \judge
    @ldcv.on \data, (host) ~> @host = host; @view.render!
    get-info = ({judge, prj}) ~> @host.data.user{}[judge.key].{}prj[prj.key] or {}
    judge-and-prj = ({ctx, ctxs}) ->
      c2 = (ctxs or []).0 or {}
      return if ctx.nickname or ctx.displayname or c2.slug => {judge: ctx, prj: c2}
      else {judge: c2, prj: ctx}
    get-prjs = ~>
      # TODO project custom-order related code are duplicated between forms.
      # (check `{disabled, filtered}` for all project.ls under each forms)
      # we should somehow integrate this into a common object.
      cfg = @host.data.cfg or {}
      custom-order = cfg["custom-order"]
      @host.prjs
        .filter (p) ~>
          !custom-order or
          !((cfg.orders or {})[p.key] or {}).disabled or
          !cfg["hide-disabled"]

    base-view =
      text:
        name: ~> @host.brd.name
        "group-name": ~> if @host.grp and @host.grp.info => @host.grp.info.name else ''
      handler:
        layout: ({node}) ~>
          node.classList.toggle \d-none, (@layout or \list) != node.getAttribute(\data-name)
        advice: ({node}) ~>
          node.classList.toggle \d-none, !(@host.data.cfg or {})["enable-advice-field"]
    child-view =
      handler:
        "has-content": ({node, ctx, ctxs}) ~>
          type = node.getAttribute \data-type
          value = node.getAttribute \data-value
          info = get-info judge-and-prj {ctx, ctxs}
          val = !!(info[type] or '').trim!
          if value == \yes => val = !val
          node.classList.toggle \d-none, val
        "advice-on": ({node}) ~>
          node.classList.toggle \d-none, !(@host.data.cfg or {})["enable-advice-field"]
        advice: ({node, ctx, ctxs}) ~>
          info = get-info judge-and-prj {ctx, ctxs}
          if info.avoid => return ''
          node.textContent = (info.advice or '').trim!
        "@": ({node, ctx, ctxs}) ~>
          info = get-info judge-and-prj {ctx, ctxs}
          node.style.background = if info.avoid => \#f2f4f5 else ''
          node.style.color = if info.avoid => \#777 else ''
        "custom-fields":
          list: ({ctx, ctxs}) ~>
            prj = judge-and-prj {ctx, ctxs} .prj
            if @host.custom-fields => @host.custom-fields({prj}) else []
          key: -> if it and it.key => it.key else it
          view: text: "@": ({ctx}) -> ctx.value
      text:
        rank: ({ctx, ctxs}) ~> @host.rank(judge-and-prj({ctx, ctxs}){prj})
        "custom-id": ({ctx,ctxs}) ~> @host.lib.idx(judge-and-prj({ctx,ctxs}){prj})
        name:({ctx,ctxs}) ~> @host.lib.info(judge-and-prj({ctx,ctxs}){prj}).name or ctx.name
        teamname: ({ctx,ctxs}) ~> @host.lib.info(judge-and-prj({ctx,ctxs}){prj}).team.name
        "judge-name": ({ctx}) -> ctx.nickname or ctx.displayname
        score: ({ctx, ctxs}) ~>
          info = get-info judge-and-prj {ctx, ctxs}
          if info.avoid => return "(迴避)"
          return @host.score(judge-and-prj({ctx, ctxs}))
        comment: ({ctx, ctxs}) ~>
          info = get-info judge-and-prj {ctx, ctxs}
          if info.avoid => return ''
          return (info.comment or '').trim!

    @view = new ldview do
      root: root
      init-render: false
      action:
        click:
          "pivot": ({node}) ~>
            @pivot = node.getAttribute(\data-name) or \judge
            @view.render!
          "change-layout": ~>
            @layout = if !@layout or @layout == \list => \nest else \list
            @view.render!
          print: ~>
            win = window.open '', 'detail-for-print'
            links = ld$.find \link
              .filter -> it.getAttribute(\rel) == \stylesheet
              .map ->
                if /^http:/.exec(href = it.getAttribute(\href)) => href
                else "#{window.location.origin}/#href"
              .map -> """<link rel="stylesheet" type="text/css" href="#it"/>"""
              .join('')
            styles = ld$.find \style
              .map -> """<style type="text/css">#{it.textContent}</style>"""
              .join('')
            styles += """<style type="text/css">#{@view.get(\ext-style).innerText}</style>"""
            win.document.body.innerHTML = ""
            win.document.write """
            <html><head>#links#styles</head>
            <body>#{@view.get('root').innerHTML}</body></html>
            """
      handler:
        "pivot": ({node}) ~> node.classList.toggle \active, node.getAttribute(\data-name) == @pivot
        "pivot-base": ({node}) ~>
          node.classList.toggle \d-none, (node.getAttribute(\data-name) != @pivot)
        "no-judge": ({node}) ~> node.classList.toggle \d-none, !!(@host.judge.users or []).length
        "overall-base": handler:
          "custom-fields":
            list: ~> if @host.custom-fields => @host.custom-fields! else []
            key: -> if it and it.key => it.key else it
            view: text: "@": ({ctx}) -> ctx.value
          prj:
            list: ~>
              ret = get-prjs!
              ret.sort (a,b) -> a.rank - b.rank
            key: ~> it.key
            view: child-view
        "prj-base": handler: prj:
          list: ~> get-prjs!
          key: ~> it.key
          view:
            text: base-view.text <<<
              "prj-name": ({ctx}) ~> @host.lib.info(prj:ctx).name or ctx.name
              teamname: ({ctx}) ~> @host.lib.info({prj:ctx}).team.name
            handler: base-view.handler <<< judge:
              list: ~> @host.judge.users
              key: ~> it.key
              view: child-view
        "judge-base": handler: judge:
          list: ~> @host.judge.users
          key: ~> it.key
          view:
            text: base-view.text <<<
              "judge-name": ({ctx}) -> ctx.nickname or ctx.displayname
            handler: base-view.handler <<< prj:
              list: ~> get-prjs!
              key: ~> it.key
              view: child-view
