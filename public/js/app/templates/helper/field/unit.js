define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/helper/field/unit.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<input type="hidden" name="unit[__type]" value="Pointer">\n<input type="hidden" name="unit[className]" value="Unit">\n<select name="unit[id]" class="span unit-select" required="' +
((__t = ( required )) == null ? '' : __t) +
'">\n  <option value="">' +
((__t = ( i18nCommon.form.select.select_value )) == null ? '' : __t) +
'</option>\n  <option value="-1">' +
((__t = ( i18nUnit.constants.new_unit )) == null ? '' : __t) +
'</option>\n</select>\n\n<input type="text" class="new-unit span1 hide" name="unit[attributes][title]" placeholder="' +
((__t = ( i18nCommon.fields.title )) == null ? '' : __t) +
'" />\n';
 if (!property) { ;
__p += '\n  \n  units.each(function(u) {\n    <option value="' +
((__t = ( u.id )) == null ? '' : __t) +
'" ';
 if (u.id == unit.id) { ;
__p += 'selected="selected"';
 } ;
__p += '>' +
((__t = ( u.get("title") )) == null ? '' : __t) +
'</option>\n  })\n  \n  No property\n  JST["src/js/templates/helper/field/property.jst"]({model: model, i18nCommon: i18nCommon, i18nLease: i18nLease})\n';
 } ;
__p += '\n\n';

}
return __p
};

  return this["JST"];
});