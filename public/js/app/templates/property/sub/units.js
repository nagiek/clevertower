this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/units.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<form id="units">\n  <header class="clearfix">\n    <h2 class="left-sm">' +
((__t = ( i18nProperty.menu.building )) == null ? '' : __t) +
'</h2>\n    <!-- <div class="well form-inline form-condensed left-lg">\n      <div class="form-group">\n        <div class="control-label">' +
((__t = ( i18nCommon.dates.date )) == null ? '' : __t) +
'</div>\n        <div class="controls">\n          <input id="date" type="text" class="input-sm" value="' +
((__t = ( today )) == null ? '' : __t) +
'">\n        </div>\n      </div>\n    </div> -->\n    <div id="units-controls" class="well well-sm form-inline right-sm">\n      <button type="button" id="units-edit" class="btn btn-default">' +
((__t = ( i18nUnit.actions.edit_units )) == null ? '' : __t) +
'</button>\n      <div id="add-units-group" class="form-group inline-block form-condensed">\n        <div class="control-label text-center">' +
((__t = ( i18nUnit.actions.add_x_units )) == null ? '' : __t) +
'</div>\n        <div class="input-group">\n          <input id="x" type="number" size="2" maxlength="2" class="form-control" value="1">\n          <span class="input-group-btn">\n            <button id="add-x" class="btn btn-info">' +
((__t = ( i18nCommon.actions.go )) == null ? '' : __t) +
'</button>\n          </span>\n        </div>\n      </div>\n      <button type="button" class="undo btn btn-default" disabled="disabled">' +
((__t = ( i18nCommon.actions.undo )) == null ? '' : __t) +
'</button>\n      <button type="button" class="save btn btn-primary">' +
((__t = ( i18nCommon.actions.save )) == null ? '' : __t) +
'</button>\n    </div>\n    <ul class="list-inline right-sm">\n      <li>\n        <a class="btn btn-success" href="' +
((__t = ( baseUrl )) == null ? '' : __t) +
'/add/lease">\n          <span class="glyphicon glyphicon-plus"></span> ' +
((__t = ( i18nProperty.menu.add_lease )) == null ? '' : __t) +
'\n        </a>\n      </li>\n    </ul>\n  </header>\n\n  <div class="table-scrollable">\n    <table id="units-table" class="table form-condensed">\n      <thead>\n        <tr>\n          <th>' +
((__t = (i18nCommon.classes.Unit)) == null ? '' : __t) +
'</th>\n          <th class="variable-begin">' +
((__t = (i18nUnit.fields.status)) == null ? '' : __t) +
'</th>\n          <th class="view-specific view-show">' +
((__t = (i18nLease.attributes.ending)) == null ? '' : __t) +
'</th>\n          ';
 if (isMgr) { ;
__p += '\n            <th class="view-specific view-show">' +
((__t = (i18nLease.attributes.rent_this_month)) == null ? '' : __t) +
'</th>\n          ';
 } ;
__p += '\n          <th class="view-specific view-edit hide">' +
((__t = (i18nUnit.fields.bedrooms)) == null ? '' : __t) +
'</th>\n          <th class="view-specific view-edit hide">' +
((__t = (i18nUnit.fields.bathrooms)) == null ? '' : __t) +
'</th>\n          <th class="view-specific view-edit hide">' +
((__t = (i18nUnit.fields.square_feet)) == null ? '' : __t) +
'</th>\n          <th><span class="element-invisible">' +
((__t = (i18nCommon.form.Operations)) == null ? '' : __t) +
'</span></th>\n        </tr>\n      </thead>\n      <tbody>\n        <tr><td class="spinner-cell" colspan="9"><img src=\'/img/misc/spinner.gif\' class=\'spinner\' alt="' +
((__t = ( i18nCommon.verbs.loading )) == null ? '' : __t) +
'" /></td></tr>\n      </tbody>\n    </table>\n  </div>\n</form>';

}
return __p
};