define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/unit/show.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<header>\n  <h2>' +
((__t = (i18nCommon.classes.Unit)) == null ? '' : __t) +
' ' +
((__t = ( title )) == null ? '' : __t) +
'</a></h2>  \n  <div>\n    <a href="/properties/' +
((__t = ( property.objectId )) == null ? '' : __t) +
'/units/' +
((__t = ( objectId )) == null ? '' : __t) +
'/edit" class="btn">\n      ' +
((__t = ( i18nCommon.actions.edit )) == null ? '' : __t) +
'\n    </a>\n    <button class="btn add-lease"\n            rel="tooltip"\n            data-original-title="' +
((__t = ( i18nUnit.actions.add_lease )) == null ? '' : __t) +
'">\n      <i class="icon-plus"></i>\n    </button>\n    <button class="btn add-task"\n            rel="tooltip"\n            data-original-title="' +
((__t = ( i18nUnit.actions.add_task )) == null ? '' : __t) +
'">\n      <i class="icon-plus"></i>\n    </button>\n  </div>\n</header>\n<div class="row">\n  <div class="span9">\n    <div class="well">\n      <h2>' +
((__t = ( i18nUnit.show.leases )) == null ? '' : __t) +
'</h2>\n      <table id="leases-table" class="table">\n        <thead>\n          <tr>\n            <th>' +
((__t = (i18nCommon.classes.Lease)) == null ? '' : __t) +
'</th>\n            <th>' +
((__t = (i18nLease.attributes.starting)) == null ? '' : __t) +
'</th>\n            <th>' +
((__t = (i18nLease.attributes.ending)) == null ? '' : __t) +
'</th>\n            <th>' +
((__t = (i18nLease.attributes.rent_this_month)) == null ? '' : __t) +
'</th>\n            <th><span class="element-invisible">' +
((__t = (i18nCommon.headers.Operations)) == null ? '' : __t) +
'</span></th>\n          </tr>\n        </thead>\n        <tbody>\n          <tr><td class="spinner-cell" colspan="5">\n            <img src=\'/img/misc/spinner.gif\' class=\'spinner\' alt="' +
((__t = ( i18nCommon.verbs.loading )) == null ? '' : __t) +
'" />\n          </td></tr>\n        </tbody>\n      </table>\n    </div>\n  </div>\n  <div class="span3">\n    ';
 if (bathrooms || bedrooms || square_feet) { ;
__p += '\n    <div>\n      <h3>' +
((__t = ( i18nUnit.show.layout )) == null ? '' : __t) +
'</h3> \n      ';
 if (parking_fee) { ;
__p += '<div><strong>' +
((__t = ( i18nUnit.fields.parking_fee )) == null ? '' : __t) +
'</strong>' +
((__t = ( parking_fee )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n      ';
 if (parking_space) { ;
__p += '<div><strong>' +
((__t = ( i18nUnit.fields.parking_space )) == null ? '' : __t) +
'</strong>' +
((__t = ( parking_space )) == null ? '' : __t) +
'</div>';
 } ;
__p += '\n      ';
 if (garage_remotes) { ;
__p += '<div><strong>' +
((__t = ( i18nUnit.fields.garage_remotes )) == null ? '' : __t) +
'</strong>' +
((__t = ( garage_remotes )) == null ? '' : __t) +
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