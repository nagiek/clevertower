define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/new/new.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<form class="property-form span12">\n  <div class="alert alert-error" style="display:none"></div>\n  ' +
((__t = ( JST["src/js/templates/property/_form.jst"]({property: property, i18nCommon: i18nCommon, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n</form>\n';

}
return __p
};

  return this["JST"];
});