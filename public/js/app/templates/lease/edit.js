this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/lease/edit.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<h2>' +
((__t = ( i18nLease.headers.edit_lease )) == null ? '' : __t) +
'</h2>\n<form class="lease-form" enctype="multipart/form-data" method="post">\n  ' +
((__t = ( JST["src/js/templates/lease/form.jst"]({isNew: false, lease: lease, dates: dates, i18nCommon: i18nCommon, i18nUnit: i18nUnit, i18nLease: i18nLease}) )) == null ? '' : __t) +
'\n  \n  <div class="form-actions">\n    <button class="save btn btn-primary">' +
((__t = ( i18nCommon.actions.save )) == null ? '' : __t) +
'</button>\n    <a href="' +
((__t = ( cancel_path )) == null ? '' : __t) +
'" class="cancel btn">' +
((__t = ( i18nCommon.actions.cancel )) == null ? '' : __t) +
'</a>\n  </div>\n  \n  <a class="remove" href="#">' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'</a>\n</form>';

}
return __p
};