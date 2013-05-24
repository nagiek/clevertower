this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/menu/show.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<ul class="dropdown-menu">\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( i18nProperty.menu.dashboard )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/tenants">' +
((__t = ( i18nProperty.menu.tenants )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/listings">' +
((__t = ( i18nProperty.menu.listings )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/message_board">' +
((__t = ( i18nProperty.menu.message_board )) == null ? '' : __t) +
'</a></li>\n</ul>';

}
return __p
};