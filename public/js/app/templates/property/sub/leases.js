define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/leases.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<form id="leases" method="post">\n  <h2>Listing units</h2>\n  \n  <div class="well form-actions form-inline form-condensed stay-right">\n    <h4>' +
((__t = ( i18nProperty.structure.units_control )) == null ? '' : __t) +
'</h4>\n  \t<div class="control-group">\n  \t\t<div class="control-label">' +
((__t = ( i18nCommon.actions.add_x_more )) == null ? '' : __t) +
'</div>\n  \t\t<div class="controls input-append">\n  \t\t\t<input id="x" type="number" size="2" maxlength="2" class="span1" value="1">\n  \t\t\t<button id="add-x" class="btn btn-info">' +
((__t = ( i18nCommon.actions.go )) == null ? '' : __t) +
'</button>\n  \t\t</div>\n  \t</div>\n  \t<button class="btn undo" disabled="disabled">' +
((__t = ( i18nCommon.actions.undo )) == null ? '' : __t) +
'</button>\n    <button class="save btn btn-primary">' +
((__t = ( i18nCommon.actions.save )) == null ? '' : __t) +
'</button>\n  </div>\n  \n  <ul class="nav nav-pills">\n    <li id="units-show" class="active"><a href="#">' +
((__t = ( i18nCommon.actions.show )) == null ? '' : __t) +
'</a></li>\n    <li id="units-edit"><a href="#">' +
((__t = ( i18nCommon.actions.edit )) == null ? '' : __t) +
'</a></li>\n  </ul>\n\n  <table id="leases-table" class="table table-condensed form-condensed">\n    <thead>\n      <tr>\n        <th>' +
((__t = (i18nCommon.classes.Unit)) == null ? '' : __t) +
'</th>\n        <th class="view-specific view-show">' +
((__t = (i18nLease.attributes.starting)) == null ? '' : __t) +
'</th>\n        <th class="view-specific view-show">' +
((__t = (i18nLease.attributes.ending)) == null ? '' : __t) +
'</th>\n        <th class="view-specific view-show">' +
((__t = (i18nLease.attributes.rent_this_month)) == null ? '' : __t) +
'</th>\n        <th><span class="element-invisible">' +
((__t = (i18nCommon.headers.Operations)) == null ? '' : __t) +
'</span></th>\n      </tr>\n    </thead>\n    <tbody>\n      <tr><td class="spinner-cell" colspan="5">\n        <img src=\'/img/misc/spinner.gif\' class=\'spinner\' alt="' +
((__t = ( i18nCommon.verbs.loading )) == null ? '' : __t) +
'" />\n      </td></tr>\n    </tbody>\n  </table>\n</form>';

}
return __p
};

  return this["JST"];
});