define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/units/units.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<form id="units" method="post">\n  <h2>Listing units</h2>\n\n  <table id="units-form" class="table">\n    <thead>\n      <tr>\n        <th>' +
((__t = (i18nCommon.classes.Unit)) == null ? '' : __t) +
'</th>\n        <th>' +
((__t = (i18nUnit.fields.status)) == null ? '' : __t) +
'</th>\n        <th>' +
((__t = (i18nUnit.fields.bedrooms)) == null ? '' : __t) +
'</th>\n        <th>' +
((__t = (i18nUnit.fields.bathrooms)) == null ? '' : __t) +
'</th>\n        <th>' +
((__t = (i18nUnit.fields.square_feet)) == null ? '' : __t) +
'</th>\n        <th>' +
((__t = (i18nUnit.fields.description)) == null ? '' : __t) +
'</th>\n        <th><span class="element-invisible">' +
((__t = (i18nCommon.headers.Operations)) == null ? '' : __t) +
'</span></th>\n      </tr>\n    </thead>\n    <tbody></tbody>\n  </table>\n\n  <div class="form-actions form-inline form-horizontal">\n    <button class="save btn btn-primary">' +
((__t = ( i18nCommon.actions.save )) == null ? '' : __t) +
'</button>\n  \t<div class="control-group">\n  \t\t<div class="control-label">' +
((__t = ( i18nCommon.actions.add_x_more )) == null ? '' : __t) +
'</div>\n  \t\t<div class="controls input-append">\n  \t\t\t<input id="x" type="text" size="2" maxlength="2" class="span1" value="1">\n  \t\t\t<button id="add-x" class="btn btn-info">' +
((__t = ( i18nCommon.actions.go )) == null ? '' : __t) +
'</button>\n  \t\t</div>\n  \t</div>\n  \t<button class="btn undo hide">' +
((__t = ( i18nCommon.actions.undo )) == null ? '' : __t) +
'</button>\n  \t<div class="control-group">\n  \t\t<div class="control-label">' +
((__t = ( i18nUnit.form.increment )) == null ? '' : __t) +
'</div>\n  \t\t<div class="controls">\n  \t\t\t<input id="increment" type="text" maxlength="4" class="span1" value="100">\n  \t\t</div>\n  \t</div>\n  </div>\n</form>';

}
return __p
};

  return this["JST"];
});