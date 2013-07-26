this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/new/wizard.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div class="container wizard">\n  <div class="row">\n    <div class="wizard-forms"></div>\n    <div class="wizard-actions span12">\n      <div class="form-actions">\n        <div class="row">\n          <button type="button" class="next btn btn-primary phone-right tablet-right offset2" disabled="disabled">\n            ' +
((__t = ( i18nCommon.actions.next )) == null ? '' : __t) +
'\n          </button>\n          <button type="button" class="back btn" disabled="disabled">' +
((__t = ( i18nCommon.actions.back )) == null ? '' : __t) +
'</button>\n          ';
 if (!setup) { ;
__p += '<a href="/inside" class="cancel btn">' +
((__t = ( i18nCommon.actions.cancel )) == null ? '' : __t) +
'</a>';
 } ;
__p += '\n        </div>\n      </div>\n    </div>\n  </div>\n</div>';

}
return __p
};