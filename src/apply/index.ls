module.exports =
  pkg:
    name: "@grantdash/prj.tdb.boilerplate"
    extend: name: "@grantdash/prj.tdb"
    dependencies: [ {name: "ldview"} ]
    i18n:
      en:
        title:
          year: "2023"
          name: "GrantDash Sample Application Form"
          date: "Application Period: To be determined, or primarily based on announcements and regulations"
        "必填項目提示": [
          "Fields marked with"
          "are required"
        ]
        "error": "please fix error"
      "zh-TW":
        title:
          year: "2023"
          name: "GrantDash 徵件評選系統範例提案表"
          date: "徵件期間：未定，或以公告、簡章記載為主"
        "必填項目提示": [
          "標示為"
          "者為必填項目。"
        ]
        "error": "請修正錯誤"

  init: ({root, ctx, manager, pubsub, i18n, t}) ->
    pubsub.fire \init, mod({root, ctx, t, pubsub, manager, bi: @_instance})

mod = ({root, ctx, t, pubsub, manager, bi}) ->
  mgr = manager
  render: ->
    # `render` is called when host decides to re-render.
    # when anything that may need a re-render, it should be called here.
    @_ldview.render!
  info:
    # subset: field identifier defined in project config,
    #   for prj data to store in prj data object.
    # TODO this should be retrieved automatically from prjdef
    #   and used only if we need a different field.
    subset: "open"
    # your field definition list for prj.tdb to initialize
    fields: fc
  init: (base) ->
    @formmgr = base.formmgr
    @ldcv = {}
    # for any additional i18n data,
    # store it in `i18n-ext = {en: ..., zh: ...}` object
    if i18n-ext? =>
      for lng, res of {en: i18n-ext.en, "zh-TW": i18n-ext.zh} =>
        block.i18n.add-resource-bundle lng, "", res, true, true
    bi.transform \i18n
    block.i18n.module.on \languageChanged, ->
    _debounce-render = debounce 350, ~> view.render!
    @_ldview = view = new ldview do
      init-render: false
      root: root
      # for any customization of your view, add it here.
      handler: {}
    @formmgr.on \change, debounce 350, ~> @optin!
    @optin!

  optin: ->
    # optin is for post action after user made some changes.
    #   e.g., enable certain fields when user choose some values.
    # we don't expliticly limit how `optin` should be implemented, 
    #   however `plugin-run` below is an example reading the `plugin` array in field definition
    #   and process based on its `type`. Only `dependency` type is supported in below example.
    # a sample complete field definition with plugin is as below:
    /*
    "project-type":
      type: "@makeform/radio"
      meta:
        title: "計劃類型"
        is-required: true
        config: values: <[personal cooperation]>
        plugin: [
          * type: \dependency
            config:
              values: <[cooperation]>
              is-required: true
              visible: true
              targets: <[incorporate-document]>
        ]
    */

    # targets is required/visible(based on `is-required` and `visible` field) only if name = val
    dependency = ({source, values, targets, is-required, visible}) ~>
      itf = fc[source].itf
      content = itf.content!
      active = if Array.isArray(values) => (content in values) else (content == values)
      required = if !is-required => !active else active
      visible = if !visible => !active else active
      for tgt in targets =>
        o = fc[tgt].itf
        c = o.serialize!
        c.is-required = active
        o.deserialize c
        @{}_visibility[tgt] = visible
    plugin-run = (k, v, p = {}) ->
      if p.type == \dependency =>
        cfg = p.{}config{values, is-required, visible}
        cfg <<< if p.config.source => {source: p.config.source, targets: [k]}
        else {source: k, targets: p.config.targets}
        dependency cfg
    for k,v of fc =>
      ((v.meta or {}).plugin or []).map -> plugin-run(k, v, it)

  brief: ->
    # this fields are used for basic prj information used by backend.
    # e.g., `name` and `description` are stored directly in db column for quick access of prj basic info.
    name: @formmgr.content("姓名")
    description: @formmgr.content("計劃簡介")
    thumb: null # thumbnail image url
