define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/menu/building.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<ul class="dropdown-menu">\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/edit">' +
((__t = ( i18nProperty.menu.edit_property )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/photos">' +
((__t = ( i18nProperty.menu.edit_photos )) == null ? '' : __t) +
'</a></li>\n  <li class="divider"></li>\n  <li><a href="/public/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( i18nProperty.menu.view_public )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/tenant/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( i18nProperty.menu.view_tenant )) == null ? '' : __t) +
'</a></li>\n</ul>';

}
return __p
};

  return this["JST"];
});