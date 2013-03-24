define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/menu/reports.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<ul class="dropdown-menu">\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/occupancy">' +
((__t = ( i18nProperty.menu.occupancy )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/income">' +
((__t = ( i18nProperty.menu.income )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/expenses">' +
((__t = ( i18nProperty.menu.expenses )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/cash">' +
((__t = ( i18nProperty.menu.cash_transactions )) == null ? '' : __t) +
'</a></li>\n  <li><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/leases">' +
((__t = ( i18nProperty.menu.lease_history )) == null ? '' : __t) +
'</a></li>\n</ul>';

}
return __p
};

  return this["JST"];
});