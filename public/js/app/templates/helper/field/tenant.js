this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/helper/field/tenant.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div class="control-group emails-group">\n  ';
 if (label) { ;
__p += '<label for="emails" class="control-label">' +
((__t = ( label )) == null ? '' : __t) +
'</label>';
 } ;
__p += '\n  <div class="controls">\n    <textarea name="emails" rows="2" class="input-block-level">';
 if (emails) { ;
__p +=
((__t = ( emails )) == null ? '' : __t);
 } ;
__p += '</textarea>\n    <p class="help-block">' +
((__t = ( i18nCommon.form.comma_separated )) == null ? '' : __t) +
'</p>\n  </div>\n</div>';

}
return __p
};