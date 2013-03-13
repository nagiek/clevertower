define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/menu/actions.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<ul class="dropdown-menu">\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/add/lease">' +
((__t = ( i18nProperty.menu.add_lease )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/add/tenants">' +
((__t = ( i18nProperty.menu.add_tenants )) == null ? '' : __t) +
'</a></li>\n  <li class="divider"></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/add/income">' +
((__t = ( i18nProperty.menu.add_income )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/add/expense">' +
((__t = ( i18nProperty.menu.add_expense )) == null ? '' : __t) +
'</a></li>\n  <li class="divider"></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/add/post">' +
((__t = ( i18nProperty.menu.add_post )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/add/task">' +
((__t = ( i18nProperty.menu.add_task )) == null ? '' : __t) +
'</a></li>\n  <li class="divider"></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/add/listing">' +
((__t = ( i18nProperty.menu.add_listing )) == null ? '' : __t) +
'</a></li>\n</ul>';

}
return __p
};

  return this["JST"];
});