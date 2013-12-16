this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/lease/show.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<header class="clearfix">\n  <hgroup class="left-sm">\n    <h2>' +
((__t = ( i18nLease.attributes.lease_on_unit )) == null ? '' : __t) +
' <span id="unit-title">' +
((__t = ( title )) == null ? '' : __t) +
'</span></h2>\n    <h4>' +
((__t = ( start_date )) == null ? '' : __t) +
' - ' +
((__t = ( end_date )) == null ? '' : __t) +
'</h4>\n  </hgroup>\n  <ul class="left-md right-sm col-md-offset-1 list-inline">\n    <li>\n      <a href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/leases/' +
((__t = ( objectId )) == null ? '' : __t) +
'/edit" class="btn btn-default">\n      ' +
((__t = ( i18nCommon.actions.edit )) == null ? '' : __t) +
'\n      </a>\n    </li>\n    <li>\n      <a href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/add/tenants?leaseId=' +
((__t = ( objectId )) == null ? '' : __t) +
'" class="btn btn-default add-tenants"\n          rel="tooltip"\n          data-original-title="' +
((__t = ( i18nLease.actions.add_tenants )) == null ? '' : __t) +
'">\n        <span class="glyphicon glyphicon-user"></span>\n      </a>\n    </li>\n    <li>\n      <a href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/leases/' +
((__t = ( objectId )) == null ? '' : __t) +
'/extend"\n          class="btn btn-default extend"\n          rel="tooltip"\n          data-original-title="' +
((__t = ( i18nLease.actions.extend )) == null ? '' : __t) +
'">\n        <span class="glyphicon glyphicon-repeat"></span>\n      </a>\n    </li>\n  </ul>\n</header>\n<div class="row">\n  <div class="col-md-';
 if (isMgr) { ;
__p += '9';
 } else { ;
__p += '12';
 } ;
__p += '">\n    <div>\n      <h3>' +
((__t = ( i18nLease.form.tenants )) == null ? '' : __t) +
'</h3> \n      <p class="empty">' +
((__t = ( i18nLease.empty.tenants )) == null ? '' : __t) +
'</p>\n      <ul id="tenants" class="row list-unstyled"></ul>\n    </div>\n    \n    ';
 if (isMgr && rent) { ;
__p += '\n    <div>\n      <h3>' +
((__t = ( i18nLease.form.payments )) == null ? '' : __t) +
'</h3> \n      <div><strong>' +
((__t = ( i18nLease.fields.rent )) == null ? '' : __t) +
':</strong> ' +
((__t = ( rent )) == null ? '' : __t) +
'</div>\n    </div>\n    ';
 } ;
__p += '\n  </div>\n  ';
 if (isMgr) { ;
__p += '\n    <div class="col-md-3">\n      ';
 if (parking_fee || parking_space || garage_remotes) { ;
__p += '\n      <div>\n        <h3>' +
((__t = ( i18nLease.form.parking )) == null ? '' : __t) +
'</h3> \n        ';
 if (parking_fee) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.parking_fee )) == null ? '' : __t) +
':</strong> ' +
((__t = ( parking_fee )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n        ';
 if (parking_space) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.parking_space )) == null ? '' : __t) +
':</strong> ' +
((__t = ( parking_space )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n        ';
 if (garage_remotes) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.garage_remotes )) == null ? '' : __t) +
':</strong> ' +
((__t = ( garage_remotes )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n      </div>\n      ';
 } ;
__p += '\n      \n      ';
 if (security_deposit || keys) { ;
__p += '\n      <div>\n        <h3>' +
((__t = ( i18nLease.form.deposit )) == null ? '' : __t) +
'</h3> \n        ';
 if (security_deposit) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.security_deposit )) == null ? '' : __t) +
':</strong> ' +
((__t = ( security_deposit )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n        ';
 if (keys) { ;
__p += '<div><strong>' +
((__t = ( i18nLease.fields.keys )) == null ? '' : __t) +
':</strong> ' +
((__t = ( keys )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n      </div>\n      ';
 } ;
__p += '\n    </div>\n  ';
 } ;
__p += '\n</div>';

}
return __p
};