define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/lease/new.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<form class="lease-form" enctype="multipart/form-data" method="post">\n  <div class="alert alert-error" style="display:none"></div>\n  ' +
((__t = ( JST["src/js/templates/lease/_form.jst"]({lease: lease, units: units, moment: moment, i18nCommon: i18nCommon, i18nUnit: i18nUnit, i18nLease: i18nLease}) )) == null ? '' : __t) +
'\n  \n  <div class="form-actions">\n    <button class="save btn btn-primary">' +
((__t = ( i18nCommon.actions.save )) == null ? '' : __t) +
'</button>\n    <a href="' +
((__t = ( cancel_path )) == null ? '' : __t) +
'>" class="btn">' +
((__t = ( i18nCommon.actions.cancel )) == null ? '' : __t) +
'</a>\n  </div>\n</form>';

}
return __p
};

  return this["JST"];
});