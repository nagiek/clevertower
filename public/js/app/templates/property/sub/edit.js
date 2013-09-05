this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/edit.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<form class="property-form" enctype="multipart/form-data">\n  ' +
((__t = ( JST["src/js/templates/property/form.jst"]({property: property, i18nCommon: i18nCommon, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n  \n  <div class="form-actions">\n    <button class="save btn btn-primary">' +
((__t = ( i18nCommon.actions.save )) == null ? '' : __t) +
'</button>\n  </div>\n  \n  <a class="remove" href="#">' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'</a>\n</form>';

}
return __p
};