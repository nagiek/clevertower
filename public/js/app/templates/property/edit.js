define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/edit.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<form class="property-form">\n  <div class="alert alert-error" style="display:none"></div>\n  ';
 require (['templates/property/form/_basic.jst', 'templates/property/form/_marketing.jst'], function(){ ;
__p += '\n    ' +
((__t = ( JST["src/js/templates/property/form/_basic.jst"]({property: property, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n    ' +
((__t = ( JST["src/js/templates/property/form/_marketing.jst"]({property: property, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n  ';
 }) ;
__p += '\n</form>';

}
return __p
};

  return this["JST"];
});