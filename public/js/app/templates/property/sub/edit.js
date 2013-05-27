this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/edit.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<form class="property-form" enctype="multipart/form-data" method="post" >\n  <fieldset>\n    <div class="control-group public-group">\n      <label for="type" class="control-label">' +
((__t = ( i18nCommon.adjectives.public )) == null ? '' : __t) +
'</label>\n      <div class="controls">\n        <div class="toggle">\n        <label class="toggle-radio" for="publicOption1">' +
((__t = ( i18nCommon.prepositions.on )) == null ? '' : __t) +
'</label>\n        <input type="radio" name="property[public]" id="publicOption1" value="1" ' +
((__t = ( property.public ? checked="checked" : '' )) == null ? '' : __t) +
'>\n        <input type="radio" name="property[public]" id="publicOption2" value="0" ' +
((__t = ( !property.public ? checked="checked" : '' )) == null ? '' : __t) +
'>\n        <label class="toggle-radio" for="publicOption2">' +
((__t = ( i18nCommon.prepositions.off )) == null ? '' : __t) +
'</label>\n      </div>\n      </div>\n    </div>\n  </fieldset>\n  ' +
((__t = ( JST["src/js/templates/property/form.jst"]({property: property, i18nCommon: i18nCommon, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n  \n  <div class="form-actions">\n    <button class="save btn btn-primary">' +
((__t = ( i18nCommon.actions.save )) == null ? '' : __t) +
'</button>\n  </div>\n  \n  <a class="remove">' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'</a>\n</form>';

}
return __p
};