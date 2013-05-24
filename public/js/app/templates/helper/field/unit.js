this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/helper/field/unit.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<input type="hidden" name="unit[__type]" value="Pointer">\n<input type="hidden" name="unit[className]" value="Unit">\n<select name="unit[id]" class="span unit-select" required="' +
((__t = ( required )) == null ? '' : __t) +
'">\n  <option value="">' +
((__t = ( i18nCommon.form.select.select_value )) == null ? '' : __t) +
'</option>\n  <option value="-1">' +
((__t = ( i18nUnit.constants.new_unit )) == null ? '' : __t) +
'</option>\n</select>\n\n<input type="text" name="unit[attributes][title]" placeholder="' +
((__t = ( i18nCommon.fields.title )) == null ? '' : __t) +
'" class="new-unit hide span1" maxlength="16">';

}
return __p
};