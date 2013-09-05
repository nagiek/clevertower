this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/new/wizard.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div class="wizard container">\n  <div class="wizard-forms row"></div>\n  <div class="form-actions row">\n    <div class="col-md-offset-2 col-md-10">\n      <span class="right-sm right-md">\n        <button type="button" class="next btn btn-primary" disabled="disabled">\n          ' +
((__t = ( i18nCommon.actions.next )) == null ? '' : __t) +
'\n        </button>\n      </span>\n      <span class="left-sm left-md">\n        <button type="button" class="back btn btn-default" disabled="disabled">' +
((__t = ( i18nCommon.actions.back )) == null ? '' : __t) +
'</button>\n        ';
 if (!setup) { ;
__p += '<a href="/inside" class="cancel btn btn-link">' +
((__t = ( i18nCommon.actions.cancel )) == null ? '' : __t) +
'</a>';
 } ;
__p += '\n      </span>\n    </div>\n  </div>\n</div>';

}
return __p
};