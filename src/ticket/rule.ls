submod.rule = ({ctx}) ->
  obj = {}
  get-rule = ~> (((@data or {}).cfg or {})rule or {})
  threshold-ticket = -> if !(t = get-rule!["threshold-ticket"]) => 0 else t
  view =
    init: dropdown: ({node}) -> new BSN.Dropdown node
    action:
      click:
        "toggle-weighting": ~>
          @tool["judge-weighting"].view.apply @mod, arguments
        switch: ({node}) ~>
          name = node.getAttribute \data-name
          @data.{}cfg.{}rule[name] = !@data.{}cfg.{}rule[name]
          @update!
          @render!
      input:
        "threshold-ticket": ({node}) ~>
          @data.{}cfg.{}rule.{}raw["threshold-ticket"] = raw = node.value
          if isNaN(+raw) or "#raw".trim! == "" => raw = NaN
          @data.{}cfg.{}rule["threshold-ticket"] = raw
          @update!
          @render!
        "point-quota": ({node}) ~>
          @data.{}cfg.{}rule["point-quota"] = if isNaN(+node.value) => 0 else +node.value
          @update!;@render!
        "max-ticket": ({node}) ~>
          @data.{}cfg.{}rule["max-ticket"] = if isNaN(+node.value) => 0 else +node.value
          @update!;@render!
        "picked-count": ({node}) ~>
          @data.{}cfg.{}rule["picked-count"] = if isNaN(+node.value) => 0 else +node.value
          @update!;@render!
      change:
        "base-rule": ({node}) ~>
          @data.{}cfg.{}rule.base = node.value
          @update!
          @render!
        "pt-ratio": ({node}) ~>
          @data.{}cfg.{}rule["pt-ratio"] = (node.value or \linear)
          @update!
          @render!

    handler:
      switch: ({node}) ~> node.classList.toggle \on, !!(get-rule![node.getAttribute \data-name])
      "show-threshold-ticket": ({node}) ~>
        r = get-rule!
        tv = threshold-ticket!
        tr = (r.raw or {})["threshold-ticket"]
        node.classList.toggle \d-none, tv == tr
      "threshold-ticket": ({node}) ~>
        node.value = node.innerText = threshold-ticket!
      "max-ticket": ({node}) ~> node.value = get-rule!["max-ticket"] or 0
      "point-quota": ({node}) ~> node.value = get-rule!["point-quota"] or 1
      "picked-count": ({node}) ~> node.value = (get-rule!["picked-count"] or 0)
      "base-rule": ({node}) ~> node.value = (get-rule!base or 't')
      "pt-ratio": ({node}) ~> node.value = (get-rule!["pt-ratio"] or 'linear')
    text:
      "weighted-value": ->
        r = get-rule!
        if r["weighted"] => \啟用 else \未啟用
      "comment-optional-value": ->
        r = get-rule!
        if r["comment-optional"] => \選填 else \必填

  {obj, view}
