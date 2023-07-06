module.exports =
  pkg:
    name: "@grantdash/prj.tdb.boilerplate", path: "qualification/index.html"
    extend: name: "@grantdash/judge", path: "qualification/user.html"
    dependencies: []
  init: ({root, context, pubsub, t, parent}) ->
    _ = (v) -> (if v => v.v else v) or 'n/a'
    form = (def, prj, field) ->
      ret = (((prj.detail or {}).custom or {})[def.config.alias or def.slug] or {})
      ret = ret[field]
      (if ret => (ret.v or ret) else null) or 'n/a'
    view = text:
      name: ({ctx}) ~> form(parent.def, ctx.prj, "作品名稱")
      teamname: ({ctx}) ~> form(parent.def, ctx.prj, "報名者名稱")
      "custom-id": ({node, ctx}) ~> parent.lib.idx prj: ctx.prj
      type: ({ctx}) ~> form(parent.def, ctx.prj, "報名類型")
    items = [
     * name: "作品影片", required: true
     * name: "作品圖片", required: true
     * name: "代表作品", required: true
     * name: "其它附件資料", required: true
     * name: "是否為本國籍", required: true
    ].map (d,i) -> d <<< {idx: i}

    pubsub.fire \subinit, {view, items}

