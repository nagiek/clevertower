this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/helper/alert.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div id="alert-' +
((__t = ( event )) == null ? '' : __t) +
'" class="alert alert-block alert-' +
((__t = ( type )) == null ? '' : __t) +
' fade in">\n  ';
 if (dismiss) { ;
__p += '<button type="button" class="close pull-right" data-dismiss="alert">&times;</button>';
 } ;
__p += '\n  <div class="inline-block">\n  ';
 if (heading) { ;
__p += '<h4 class="alert-heading">' +
((__t = ( heading )) == null ? '' : __t) +
'</h4>';
 } ;
__p += '\n  ';
 if (message) { ;
__p += '<p class="message">' +
((__t = ( message )) == null ? '' : __t) +
'</p>';
 } ;
__p += '\n  ';
 if (buttons) { ;
__p += '<p class="buttons">' +
((__t = ( buttons )) == null ? '' : __t) +
'</p>';
 } ;
__p += '\n  </div>\n</div>';

}
return __p
};