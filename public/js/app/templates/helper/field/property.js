define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/helper/field/property.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<select name="lease[unit]" id="lease-unit" class="span2" required="true">\n  <option value="">' +
((__t = ( i18nCommon.form.select.select_value )) == null ? '' : __t) +
'</option>\n  ';
 units.each(function(unit) { ;
__p += '\n    <option value="' +
((__t = ( unit.id )) == null ? '' : __t) +
'">' +
((__t = ( unit.title )) == null ? '' : __t) +
'</option>\n  ';
 }) ;
__p += '\n  <option value="-1">' +
((__t = ( i18nCommon.constants.new_unit )) == null ? '' : __t) +
'</option>\n</select>';

}
return __p
};

  return this["JST"];
});