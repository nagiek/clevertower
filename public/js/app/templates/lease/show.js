define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/lease/show.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<header class="row">\n  <hgroup class="span">\n    <h2>' +
((__t = ( i18nLease.attributes.lease_on_unit )) == null ? '' : __t) +
' <a href="/properties/' +
((__t = ( propertyId )) == null ? '' : __t) +
'/units/' +
((__t = ( unitId )) == null ? '' : __t) +
'">' +
((__t = (title )) == null ? '' : __t) +
'</a></h2>\n    <h3>' +
((__t = ( start_date )) == null ? '' : __t) +
' - ' +
((__t = ( end_date )) == null ? '' : __t) +
'</h3>\n  </hgroup>\n  <div class="span offset1">\n    <a href="/properties/' +
((__t = ( property.objectId )) == null ? '' : __t) +
'/leases/' +
((__t = ( objectId )) == null ? '' : __t) +
'/edit" class="btn">\n      ' +
((__t = ( i18nCommon.actions.edit )) == null ? '' : __t) +
'\n    </a>\n    <button class="btn add-tenants"\n            rel="tooltip"\n            data-original-title="' +
((__t = ( i18nLease.actions.add_tenants )) == null ? '' : __t) +
'">\n      <i class="icon-user"></i>\n    </button>\n    <button class="btn extend"\n            rel="tooltip"\n            data-original-title="' +
((__t = ( i18nLease.actions.extend )) == null ? '' : __t) +
'">\n      <i class="icon-repeat"></i>\n    </button>\n    <button class="btn btn-danger delete"\n            rel="tooltip"\n            data-original-title="' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'">\n      <i class="icon-trash icon-white"></i>\n    </button>\n  </div>\n</header>\n<div class="row">\n  <div class="span9">\n    <div>\n      <h3>' +
((__t = ( i18nLease.form.tenants )) == null ? '' : __t) +
'</h3> \n      <p class="empty">' +
((__t = ( i18nLease.tenants.empty )) == null ? '' : __t) +
'</p>\n      <ul class="row no-bullet tenants"></ul>\n    </div>\n    \n    ';
 if (rent) { ;
__p += '\n    <div>\n      <h3>' +
((__t = ( i18nLease.form.payments )) == null ? '' : __t) +
'</h3> \n      ';
 if (rent) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.rent )) == null ? '' : __t) +
'</strong>' +
((__t = ( rent )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n    </div>\n    ';
 } ;
__p += '\n  </div>\n  <div class="span3">\n    ';
 if (parking_fee || parking_space || garage_remotes) { ;
__p += '\n    <div>\n      <h3>' +
((__t = ( i18nLease.form.parking )) == null ? '' : __t) +
'</h3> \n      ';
 if (parking_fee) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.parking_fee )) == null ? '' : __t) +
'</strong>' +
((__t = ( parking_fee )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n      ';
 if (parking_space) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.parking_space )) == null ? '' : __t) +
'</strong>' +
((__t = ( parking_space )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n      ';
 if (garage_remotes) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.garage_remotes )) == null ? '' : __t) +
'</strong>' +
((__t = ( garage_remotes )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n    </div>\n    ';
 } ;
__p += '\n    \n    ';
 if (security_deposit || keys) { ;
__p += '\n    <div>\n      <h3>' +
((__t = ( i18nLease.form.deposit )) == null ? '' : __t) +
'</h3> \n      ';
 if (security_deposit) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.security_deposit )) == null ? '' : __t) +
'</strong>' +
((__t = ( security_deposit )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n      ';
 if (keys) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.keys )) == null ? '' : __t) +
'</strong>' +
((__t = ( keys )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n    </div>\n    ';
 } ;
__p += '\n  </div>\n</div>';

}
return __p
};

  return this["JST"];
});