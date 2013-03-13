define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/units/structure.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<th class="view-specific view-structure">' +
((__t = (i18nUnit.fields.bedrooms)) == null ? '' : __t) +
'</th>\n<th class="view-specific view-structure">' +
((__t = (i18nUnit.fields.bathrooms)) == null ? '' : __t) +
'</th>\n<th class="view-specific view-structure">' +
((__t = (i18nUnit.fields.square_feet)) == null ? '' : __t) +
'</th>\n<th class="view-specific view-structure">' +
((__t = (i18nUnit.fields.description)) == null ? '' : __t) +
'</th>';

}
return __p
};

  return this["JST"];
});