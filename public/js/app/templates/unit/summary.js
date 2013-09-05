this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/unit/summary.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<td class="title-group">\n  <div class="view-specific view-show';
 if (editing) { ;
__p += ' hide';
 } ;
__p += ' ">\n    ';
 if (objectId) { ;
__p += '\n      ' +
((__t = ( title )) == null ? '' : __t) +
'\n      ';
 if (activeLease) { ;
__p += '\n        | <a href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/leases/' +
((__t = ( activeLease.id )) == null ? '' : __t) +
'">' +
((__t = ( i18nCommon.classes.lease )) == null ? '' : __t) +
'</a>\n      ';
 } ;
__p += '\n    ';
 } ;
__p += '\n  </div>\n  ';
 if (objectId) { ;
__p += '<div class="view-specific view-edit';
 if (!editing) { ;
__p += ' hide';
 } ;
__p += '">';
 } ;
__p += '\n    <div class="form-group">\n      <input type="text" maxlength="8" name="title" class="form-control title" value="' +
((__t = ( title )) == null ? '' : __t) +
'">\n    </div>\n  ';
 if (objectId) { ;
__p += '</div>';
 } ;
__p += '\n</td>\n<td>\n  ';
 if (isNew) { ;
__p += '\n    <span class="label label-warning">' +
((__t = ( i18nCommon.status.unsaved )) == null ? '' : __t) +
'</span>\n  ';
 } else { ;
__p += '  \n    ';
 if (activeLease) { ;
__p += '\n      <span class="label label-success">' +
((__t = ( i18nCommon.status.ok )) == null ? '' : __t) +
'</span>\n    ';
 } else { ;
__p += '\n      <span class="label label-important">' +
((__t = ( i18nCommon.status.vacant )) == null ? '' : __t) +
'</span>\n    ';
 } ;
__p += '\n  ';
 } ;
__p += '\n</td>\n<td class="view-specific view-show';
 if (editing) { ;
__p += ' hide';
 } ;
__p += '">\n  ';
 if (activeLease && end_date) { ;
__p += '\n    ' +
((__t = ( end_date )) == null ? '' : __t) +
'\n  ';
 } ;
__p += '\n</td>\n';
 if (isMgr) { ;
__p += '\n  <td class="view-specific view-show';
 if (editing) { ;
__p += ' hide';
 } ;
__p += '">\n    ';
 if (activeLease && activeLease.get("rent")) { ;
__p += '\n      ' +
((__t = ( activeLease.get("rent") )) == null ? '' : __t) +
'\n    ';
 } ;
__p += '\n  </td>\n';
 } ;
__p += '\n<td class="view-specific view-edit';
 if (!editing) { ;
__p += ' hide';
 } ;
__p += '">\n  <div class="form-group bedrooms-group">\n    <select class="form-control" name="bedrooms">\n      <option value="0" ' +
((__t = ( bedrooms == 0 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.zero )) == null ? '' : __t) +
'</option>\n      <option value="1" ' +
((__t = ( bedrooms == 1 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.one )) == null ? '' : __t) +
'</option>\n      <option value="2" ' +
((__t = ( bedrooms == 2 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.two )) == null ? '' : __t) +
'</option>\n      <option value="3" ' +
((__t = ( bedrooms == 3 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.three )) == null ? '' : __t) +
'</option>\n      <option value="4" ' +
((__t = ( bedrooms == 4 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.four )) == null ? '' : __t) +
'</option>\n      <option value="5" ' +
((__t = ( bedrooms == 5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.five )) == null ? '' : __t) +
'</option>\n    </select>\n  </div>\n</td>\n<td class="view-specific view-edit';
 if (!editing) { ;
__p += ' hide';
 } ;
__p += '">\n  <div class="form-group bathrooms-group">\n    <select name="bathrooms" class="form-control">\n      <option value="0" ' +
((__t = ( bathrooms == 0 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.zero )) == null ? '' : __t) +
'</option>\n      <option value="1" ' +
((__t = ( bathrooms == 1 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.one )) == null ? '' : __t) +
'</option>\n      <option value="1.5" ' +
((__t = ( bathrooms == 1.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.oneandahalf )) == null ? '' : __t) +
'</option>\n      <option value="2" ' +
((__t = ( bathrooms == 2 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.two )) == null ? '' : __t) +
'</option>\n      <option value="2.5" ' +
((__t = ( bathrooms == 2.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.twoandahalf )) == null ? '' : __t) +
'</option>\n      <option value="3" ' +
((__t = ( bathrooms == 3 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.three )) == null ? '' : __t) +
'</option>\n      <option value="3.5" ' +
((__t = ( bathrooms == 3.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.threeandahalf )) == null ? '' : __t) +
'</option>\n    </select>\n  </div>\n</td>\n<td class="view-specific view-edit';
 if (!editing) { ;
__p += ' hide';
 } ;
__p += '">\n  <div class="square-feet-group form-group">\n    <div class="input-group">\n      <input type="text" maxlength="6" name="square_feet" class="form-control" value="' +
((__t = ( square_feet )) == null ? '' : __t) +
'">\n      <div class="input-group-addon">' +
((__t = ( i18nUnit.form.squarefeetsymbol )) == null ? '' : __t) +
'</div>\n    </div>\n  </div>\n</td>\n<td>\n  ';
 if (objectId) { ;
__p += '\n    <a class="btn btn-link add-lease view-specific view-show';
 if (editing) { ;
__p += ' hide';
 } ;
__p += '"\n       href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/add/lease?unitId=' +
((__t = ( objectId )) == null ? '' : __t) +
'" \n       rel="tooltip" \n       title="' +
((__t = ( i18nLease.actions.add_new_lease )) == null ? '' : __t) +
'">\n      <span class="glyphicon glyphicon-plus"></span>\n    </a>\n    <a class="btn btn-link add-listing view-specific view-show';
 if (editing) { ;
__p += ' hide';
 } ;
__p += '"\n       href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/add/listing?unitId=' +
((__t = ( objectId )) == null ? '' : __t) +
'"\n       rel="tooltip" \n       title="' +
((__t = ( i18nListing.actions.add_listing )) == null ? '' : __t) +
'">\n      <span class="glyphicon glyphicon-certificate glyphicon-listing"></span>\n    </a>\n    ';
 if (activeLease) { ;
__p += '\n      <a class="btn btn-link add-tenants view-specific view-show';
 if (editing) { ;
__p += ' hide';
 } ;
__p += '"\n         href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/add/tenants?leaseId=' +
((__t = ( activeLease.id )) == null ? '' : __t) +
'" \n         rel="tooltip" \n         title="' +
((__t = ( i18nLease.actions.add_tenants )) == null ? '' : __t) +
'">\n        <span class="glyphicon glyphicon-user"></span>\n      </a>\n      <a class="btn btn-link extend view-specific view-show';
 if (editing) { ;
__p += ' hide';
 } ;
__p += '"\n         href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/leases/' +
((__t = ( activeLease.id )) == null ? '' : __t) +
'/extend"\n         rel="tooltip" \n         title="' +
((__t = ( i18nLease.actions.extend )) == null ? '' : __t) +
'">\n        <span class="glyphicon glyphicon-repeat"></span>\n      </a>\n    ';
 } ;
__p += '\n    <span class="view-specific view-edit';
 if (!editing) { ;
__p += ' hide';
 } ;
__p += '">\n      <button class="btn btn-small btn-danger delete view-specific view-edit';
 if (!editing) { ;
__p += ' hide';
 } ;
__p += '"\n              rel="tooltip"\n              data-original-title="' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'">\n        <span class="glyphicon glyphicon-trash"></span>\n      </button>\n    </span>\n  ';
 } else { ;
__p += '\n    <span class="view-specific view-edit';
 if (!editing) { ;
__p += ' hide';
 } ;
__p += '">\n      <button class="btn btn-small btn-danger remove">' +
((__t = ( i18nCommon.actions.remove )) == null ? '' : __t) +
'</button>\n    </span>\n  ';
 } ;
__p += '\n</td>';

}
return __p
};