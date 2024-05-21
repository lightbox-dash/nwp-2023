submod.download = ({ctx, t}) ->
  {csv4xls, ldfile} = ctx
  obj = run: ~>
    group-rule = ((@data.cfg or {}).group or {})
    jhead = @judge.users
      .map (d,i) ~>
        n = if @judge.form.config.anonymous => "評審#{i + 1}" else (d.nickname or d.displayname)
        [ "#{n}票數", "#{n}評論" ]
      .reduce(((a,b) -> a ++ b), [])
    #ohead = @options.list!map -> "#{it.name}票數"
    budget-on = false
    head = (
      <[序位 編號]> ++
      (if group-rule.enabled => <[分組]> else []) ++
      <[名稱 申請單位]> ++ (if budget-on => <[計劃總經費(元) 申請經費(元) 申請經費佔比]> else []) ++
      jhead ++
      #ohead ++
      #<[得票佔比]> ++
      <[入選標記 會前加註 會中加註]>
    )
    head = head.map(-> "#it")
    body = @submod.project.utils.filtered!
      .map (p) ~>
        id = @lib.idx prj: p
        info = @lib.info prj: p
        stat = @pm.get(p)
        js = @judge.users.filter((j) ~> !@data.{}user{}[j.key].{}prj{}[p.key].avoid)
        budget-total = info.budget.total
        budget-subsidy = info.budget["expected-subsidy"]
        subsidy-percent = (100 * (budget-subsidy or 0) / (budget-total or 1)).toFixed(2)
        if isNaN(Number(subsidy-percent)) => subsidy-percent = "?"
        else subsidy-percent = "#{subsidy-percent}%"
        group = @get-group({prj: p}).info.name or 'n/a'

        result = @result-mark {prj: p}

        ret = (
          [
            stat.rank
            id
          ] ++
          (if group-rule.enabled => [ group ] else []) ++
          [
            p.name,
            info.team.name,
          ] ++ (if budget-on => [
            budget-total,
            budget-subsidy,
            subsidy-percent
          ] else []) ++ (
          @judge.users
            .map (d,i) ~>
              pinfo = @data.user{}[d.key].{}prj[p.key] or {}
              [
                if pinfo.avoid => '(迴避)' else (pinfo.v or 0)
                pinfo.comment or ''
              ]
            .reduce(((a,b) -> a ++ b), [])
          ) ++ /*@options.list!map(-> stat.count[it.key]) ++*/ [
            #"#{(stat.rate * 100).toFixed(2)}%",
            result.mark,
            ((@data.prj or {})[p.key] or {}).prenote or ''
            ((@data.prj or {})[p.key] or {}).note or ''
          ]
        )
    csv = [head] ++ body
    blob = csv4xls.toBlob csv
    href = URL.createObjectURL blob
    ldfile.download {blob, mime: "text/csv", name: "#{@judge.form.name}-#{@brd.name}.csv"}
  {obj, view: {}}
