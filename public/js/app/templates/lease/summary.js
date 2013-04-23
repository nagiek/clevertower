define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/lease/summary.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<td>\n  ';
 if (!onUnit) { ;
__p += '<a href="/properties/' +
((__t = ( propertyId )) == null ? '' : __t) +
'/units/' +
((__t = ( unitId )) == null ? '' : __t) +
'">' +
((__t = ( unitTitle )) == null ? '' : __t) +
'</a> |';
 };
__p += '\n  <a href="/properties/' +
((__t = ( propertyId )) == null ? '' : __t) +
'/leases/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( link_text )) == null ? '' : __t) +
'</a>\n</td>\n<td>' +
((__t = ( start_date )) == null ? '' : __t) +
'</td>\n<td>' +
((__t = ( end_date )) == null ? '' : __t) +
'</td>\n<td>' +
((__t = ( rent )) == null ? '' : __t) +
'</td>\n<td>\n  ';
 if (objectId) { ;
__p += '\n    <a href="/properties/' +
((__t = ( property.objectId )) == null ? '' : __t) +
'/leases/' +
((__t = ( objectId )) == null ? '' : __t) +
'/edit" class="btn btn-mini">\n      ' +
((__t = ( i18nCommon.actions.edit )) == null ? '' : __t) +
'\n    </a>\n    <button class="btn btn-mini add-tenants"\n            rel="tooltip"\n            data-original-title="' +
((__t = ( i18nLease.actions.add_tenants )) == null ? '' : __t) +
'">\n      <i class="icon-user"></i>\n    </button>\n    <button class="btn btn-mini extend"\n            rel="tooltip"\n            data-original-title="' +
((__t = ( i18nLease.actions.extend )) == null ? '' : __t) +
'">\n      <i class="icon-repeat"></i>\n    </button>\n    <button class="btn btn-mini btn-danger delete"\n            rel="tooltip"\n            data-original-title="' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'">\n      <i class="icon-trash icon-white"></i>\n    </button>\n  ';
 } else { ;
__p += '\n    <button class="btn btn-mini btn-danger remove">' +
((__t = ( i18nCommon.actions.remove )) == null ? '' : __t) +
'</button>\n  ';
 } ;
__p += '\n</td>';

}
return __p
};

  return this["JST"];
});