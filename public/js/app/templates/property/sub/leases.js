this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/leases.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<form id="leases" method="post">\n  <h2>Listing units</h2>\n\n  <table id="leases-table" class="table form-condensed">\n    <thead>\n      <tr>\n        <th>' +
((__t = (i18nCommon.classes.Unit)) == null ? '' : __t) +
'</th>\n        <th class="view-specific view-show">' +
((__t = (i18nLease.attributes.starting)) == null ? '' : __t) +
'</th>\n        <th class="view-specific view-show">' +
((__t = (i18nLease.attributes.ending)) == null ? '' : __t) +
'</th>\n        <th class="view-specific view-show">' +
((__t = (i18nLease.attributes.rent_this_month)) == null ? '' : __t) +
'</th>\n        <th><span class="element-invisible">' +
((__t = (i18nCommon.form.Operations)) == null ? '' : __t) +
'</span></th>\n      </tr>\n    </thead>\n    <tbody>\n      <tr><td class="spinner-cell" colspan="5">\n        <img src=\'/img/misc/spinner.gif\' class=\'spinner\' alt="' +
((__t = ( i18nCommon.verbs.loading )) == null ? '' : __t) +
'" />\n      </td></tr>\n    </tbody>\n  </table>\n</form>';

}
return __p
};