submod.monitor = ({ctx}) ->
  get = ~>
    return @judge.users.map (j) ~>
      ret = {judge: j, value: val = {}}
      @prjs.map (p) ~>
        d = (((@data.user or {})[j.key] or {}).prj or {})[p.key]
        if d.avoid => return
        val.count = (val.count or 0) + 1
        if d.comment => val.comment = (val.comment or 0) + 1
        if d.v? => val.score = (val.score or 0) + 1
      ret
  view = handler: judge:
    list: ~> get!
    key: -> it.judge.key
    view:
      text:
        score: ({ctx}) -> ctx.value.score or 0
        comment: ({ctx}) -> ctx.value.comment or 0
        count: ({ctx}) -> ctx.value.count or 0
        "used-point": ({ctx}) ~> ((@data.user or {})[ctx.judge.key] or {})["used-point"] or 0
        "total-point": ({ctx}) ~> ((@data.cfg or {}).rule or {})["point-quota"] or 1
      handler:
        name: ({node, ctx}) -> node.innerText = ctx.judge.nickname or ctx.judge.displayname
        "progress-point": ({node, ctx}) ~>
          p = ((@data.user or {})[ctx.judge.key] or {})["used-point"] or 0
          q = ((@data.cfg or {}).rule or {})["point-quota"] or 1
          node.style.width = "#{100 * p / q}%"
        "progress-comment": ({node, ctx}) ->
          node.style.width = "#{100 * ((ctx.value.comment or 0) / (ctx.value.count or 1))}%"
  {view}
