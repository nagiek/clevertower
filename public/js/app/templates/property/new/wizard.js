define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/new/wizard.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class="form-actions">\n  <button class="next btn btn-primary">' +
((__t = ( i18nCommon.actions.next )) == null ? '' : __t) +
'</button>\n  <button class="back btn" disabled="disabled">' +
((__t = ( i18nCommon.actions.back )) == null ? '' : __t) +
'</button>\n  <button class="cancel btn">' +
((__t = ( i18nCommon.actions.cancel )) == null ? '' : __t) +
'</button>\n</div>\n';

}
return __p
};

  return this["JST"];
});