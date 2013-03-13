define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/units/current.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<th class="view-specific view-occupancy">' +
((__t = (i18nLease.attributes.ending)) == null ? '' : __t) +
'</th>\n<th class="view-specific view-occupancy">' +
((__t = (i18nLease.attributes.rent_this_month)) == null ? '' : __t) +
'</th>';

}
return __p
};

  return this["JST"];
});