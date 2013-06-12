this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/menu/actions.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<ul class="dropdown-menu">\n  <li><a href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/add/lease">' +
((__t = ( i18nProperty.menu.add_lease )) == null ? '' : __t) +
'</a></li>\n  <li><a href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/add/tenants">' +
((__t = ( i18nProperty.menu.add_tenants )) == null ? '' : __t) +
'</a></li>\n  <li><a href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/add/listing">' +
((__t = ( i18nProperty.menu.add_listing )) == null ? '' : __t) +
'</a></li>\n</ul>';

}
return __p
};