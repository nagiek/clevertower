define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/unit/status.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 if (confirmed) { ;
__p += '\n  ';
 if (has_lease) { ;
__p += '\n    <span class="label label-success">' +
((__t = ( i18nUnit.status.confirmed )) == null ? '' : __t) +
'</span>\n  ';
 } else { ;
__p += '\n    <span class="label label-error">' +
((__t = ( i18nUnit.status.vacant )) == null ? '' : __t) +
'</span>\n  ';
 } ;
__p += '\n';
 } else { ;
__p += '\n  <span class="label label-warning">' +
((__t = ( i18nUnit.status.pending )) == null ? '' : __t) +
'</span>\n';
 } ;


}
return __p
};

  return this["JST"];
});