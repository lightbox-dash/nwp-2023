window.lib = function(arg$){
  var def, i18n;
  def = arg$.def, i18n = arg$.i18n;
  return {
    idx: function(arg$){
      var prj, idx;
      prj = arg$.prj;
      idx = (prj.system || {}).idx;
      if (!(idx != null)) {
        return '???';
      } else if (isNaN(idx)) {
        return idx;
      } else {
        return "2023-" + (idx + "").padStart(3, "0");
      }
    },
    info: function(arg$){
      var prj, _, form, lng, data;
      prj = arg$.prj;
      _ = function(v){
        return (v ? v.v : v) || 'n/a';
      };
      form = ((prj.detail || {}).custom || {})[def.config.alias || def.slug] || {};
      lng = i18n.getLanguage();
      return data = {
        name: _(form["姓名"]),
        description: _(form["個人簡介"]),
        team: {
          name: _(form["姓名"]),
          taxid: "",
          pic: ""
        },
        contact: {
          email: _(form["聯絡EMAIL"]),
          name: _(form["姓名"]),
          mobile: _(form["聯絡電話"]),
          title: "",
          addr: ""
        },
        budget: {
          total: 0,
          "expected-subsidy": 0
        }
      };
    }
  };
};
