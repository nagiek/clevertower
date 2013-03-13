define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/unit/summary.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<td class="title-group">\n  <div class="view-specific view-show">\n    ';
 if (objectId) { ;
__p += '\n      <a class="unit-link" href="/properties/' +
((__t = ( property.objectId )) == null ? '' : __t) +
'/units/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( title )) == null ? '' : __t) +
'</a>\n      ';
 if (has_lease) { ;
__p += '\n        | <a href="/properties/' +
((__t = ( property.objectId )) == null ? '' : __t) +
'/lease/' +
((__t = ( activeLease.objectId )) == null ? '' : __t) +
'">' +
((__t = ( i18nCommmon.classes.lease )) == null ? '' : __t) +
'</a>\n      ';
 } ;
__p += '\n    ';
 } ;
__p += '\n  </div>\n  ';
 if (objectId) { ;
__p += '<div class="view-specific view-edit hide">';
 } ;
__p += '\n    <div class="control-group">\n  \t\t<div class="controls">\n  \t\t\t<input type="text" maxlength="8" name="title" class="span1" value="' +
((__t = ( title )) == null ? '' : __t) +
'">\n  \t\t</div>\n  \t</div>\n  ';
 if (objectId) { ;
__p += '</div>';
 } ;
__p += '\n</td>\n<td>\n  ';
 if (isNew) { ;
__p += '\n    <span class="label label-warning">' +
((__t = ( i18nUnit.status.unsaved )) == null ? '' : __t) +
'</span>\n  ';
 } else { ;
__p += '  \n    ';
 if (confirmed) { ;
__p += '\n      ';
 if (has_lease) { ;
__p += '\n        <span class="label label-success">' +
((__t = ( i18nUnit.status.confirmed )) == null ? '' : __t) +
'</span>\n      ';
 } else { ;
__p += '\n        <span class="label label-important">' +
((__t = ( i18nUnit.status.vacant )) == null ? '' : __t) +
'</span>\n      ';
 } ;
__p += '\n    ';
 } else { ;
__p += '\n      <span class="label label-info">' +
((__t = ( i18nUnit.status.pending )) == null ? '' : __t) +
'</span>\n    ';
 } ;
__p += '\n  ';
 } ;
__p += '\n</td>\n<td class="view-specific view-show">\n  ';
 if (has_lease && active_lease.end_date) { ;
__p += '\n    <span content="' +
((__t = ( active_lease.end_date )) == null ? '' : __t) +
'" datatype="xsd:dateTime" property="dc:date">\n      ' +
((__t = ( moment(active_lease.end_date).format("MMM DD YYYY") )) == null ? '' : __t) +
'\n    </span>  \n  ';
 } ;
__p += '\n</td>\n<td class="view-specific view-show">\n  ';
 if (has_lease && active_lease.rent) { ;
__p += '\n    ' +
((__t = ( active_lease.rent )) == null ? '' : __t) +
'\n  ';
 } ;
__p += '\n</td>\n<td class="view-specific view-edit hide">\n  <div class="control-group">\n\t\t<div class="controls">\n\t\t\t<select value="' +
((__t = ( bedrooms )) == null ? '' : __t) +
'" name="bedrooms">\n\t\t\t  <option value="0" ' +
((__t = ( bedrooms == 0 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.zero )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="1" ' +
((__t = ( bedrooms == 1 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.one )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="2" ' +
((__t = ( bedrooms == 2 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.two )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="3" ' +
((__t = ( bedrooms == 3 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.three )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="4" ' +
((__t = ( bedrooms == 4 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.four )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="5" ' +
((__t = ( bedrooms == 5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.five )) == null ? '' : __t) +
'</option>\n\t\t\t</select>\n\t\t</div>\n\t</div>\n</td>\n<td class="view-specific view-edit hide">\n  <div class="control-group">\n\t\t<div class="controls">\n\t\t\t<select name="bathrooms">\n\t\t\t  <option value="0" ' +
((__t = ( bathrooms == 0 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.zero )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="1" ' +
((__t = ( bathrooms == 1 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.one )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="1.5" ' +
((__t = ( bathrooms == 1.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.oneandahalf )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="2" ' +
((__t = ( bathrooms == 2 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.two )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="2.5" ' +
((__t = ( bathrooms == 2.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.twoandahalf )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="3" ' +
((__t = ( bathrooms == 3 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.three )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="3.5" ' +
((__t = ( bathrooms == 3.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.threeandahalf )) == null ? '' : __t) +
'</option>\n\t\t\t</select>\n\t\t</div>\n\t</div>\n</td>\n<td class="view-specific view-edit hide">\n  <div class="control-group">\n\t\t<div class="controls input-append">\n\t\t\t<input type="text" maxlength="6" name="square_feet" class="span1" value="' +
((__t = ( square_feet )) == null ? '' : __t) +
'">\n\t\t\t<div class="add-on">' +
((__t = ( i18nUnit.form.squarefeetsymbol )) == null ? '' : __t) +
'</div>\n\t\t</div>\n\t</div>\n</td>\n<td class="view-specific view-edit hide">\n  <div class="control-group">\n\t\t<div class="controls">\n      <textarea class="span4" name="description" rows="2">' +
((__t = ( description )) == null ? '' : __t) +
'</textarea>\n\t\t</div>\n\t</div>\n</td>\n<td>\n  ';
 if (objectId) { ;
__p += '\n    <a class="btn btn-mini add-lease"\n       href="/properties/' +
((__t = ( property.objectId )) == null ? '' : __t) +
'/units/' +
((__t = ( objectId )) == null ? '' : __t) +
'/add/lease" \n       rel="tooltip" \n       data-original-title="' +
((__t = ( i18nUnit.actions.add_lease )) == null ? '' : __t) +
'">\n      <i class="icon-plus"></i>\n    </a>\n    ';
 if (has_lease) { ;
__p += '\n      <a class="btn btn-mini add-tenants"\n         href="/properties/' +
((__t = ( property.objectId )) == null ? '' : __t) +
'/leases/' +
((__t = ( active_lease.objectId )) == null ? '' : __t) +
'/add/tenants" \n         rel="tooltip" \n         data-original-title="' +
((__t = ( i18nLease.actions.add_tenants )) == null ? '' : __t) +
'">\n        <i class="icon-user"></i>\n      </a>\n      <a class="btn btn-mini extend"\n         href="/properties/' +
((__t = ( property.objectId )) == null ? '' : __t) +
'/leases/' +
((__t = ( active_lease.objectId )) == null ? '' : __t) +
'/add/task" \n         rel="tooltip" \n         data-original-title="' +
((__t = ( i18nLease.actions.extend )) == null ? '' : __t) +
'">\n        <i class="icon-repeat"></i>\n      </a>\n    ';
 } ;
__p += '\n    <button class="btn btn-mini btn-danger delete"\n            rel="tooltip"\n            data-original-title="' +
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