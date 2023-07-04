window.lib = ({def, i18n}) ->
  idx: ({prj}) ->
    idx = (prj.system or {}).idx
    if !(idx?) => \???
    else if isNaN(idx) => idx
    else "2023-" + "#idx".padStart(3, "0")
  info: ({prj}) ->
    _ = (v) -> (if v => v.v else v) or 'n/a'
    form = ((prj.detail or {}).custom or {})[def.config.alias or def.slug] or {}
    lng = i18n.getLanguage!
    data =
      name: _(form["姓名"])
      description: _(form["個人簡介"])
      team:
        name: _(form["姓名"])
        taxid: ""
        pic: ""
      contact:
        email: _(form["聯絡EMAIL"])
        name: _(form["姓名"])
        mobile: _(form["聯絡電話"])
        title: ""
        addr: ""
      budget:
        total: 0
        "expected-subsidy": 0
