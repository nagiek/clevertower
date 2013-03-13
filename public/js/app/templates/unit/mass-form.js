define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/unit/mass-form.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<tr>\n  <td>\n    <div class="control-group">\n  \t\t<div class="controls input-append">\n  \t\t\t<input type="text" maxlength="6" class="span1" value="' +
((__t = ( title )) == null ? '' : __t) +
'">\n  \t\t\t<div class="add-on">\n  \t\t\t  <a href="unit/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( i18nUnit.form.unit_info )) == null ? '' : __t) +
'</a>\n        </div>\n  \t\t</div>\n  \t</div>\n  </td>\n  <td>' +
((__t = ( JST["src/js/templates/unit/status.jst"]({activeLease: activeLease}) )) == null ? '' : __t) +
'</td>\n  <td>\n    <div class="control-group">\n  \t\t<div class="controls">\n  \t\t\t<select value="' +
((__t = ( bedrooms )) == null ? '' : __t) +
'">\n  \t\t\t  <option value="0">' +
((__t = ( i18nUnit.form.bedrooms.zero )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="1">' +
((__t = ( i18nUnit.form.bedrooms.one )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="2">' +
((__t = ( i18nUnit.form.bedrooms.two )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="3">' +
((__t = ( i18nUnit.form.bedrooms.three )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="4">' +
((__t = ( i18nUnit.form.bedrooms.four )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="5">' +
((__t = ( i18nUnit.form.bedrooms.five )) == null ? '' : __t) +
'</option>\n  \t\t\t</select>\n  \t\t</div>\n  \t</div>\n  </td>\n  <td>\n    <div class="control-group">\n  \t\t<div class="controls">\n  \t\t\t<select value="' +
((__t = ( bathrooms )) == null ? '' : __t) +
'">\n  \t\t\t  <option value="0">' +
((__t = ( i18nUnit.form.bedrooms.zero )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="1">' +
((__t = ( i18nUnit.form.bedrooms.one )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="1.5">' +
((__t = ( i18nUnit.form.bedrooms.oneandahalf )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="2">' +
((__t = ( i18nUnit.form.bedrooms.two )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="2.5">' +
((__t = ( i18nUnit.form.bedrooms.twoandahalf )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="3">' +
((__t = ( i18nUnit.form.bedrooms.three )) == null ? '' : __t) +
'</option>\n  \t\t\t  <option value="3.5">' +
((__t = ( i18nUnit.form.bedrooms.threeandahalf )) == null ? '' : __t) +
'</option>\n  \t\t\t</select>\n  \t\t</div>\n  \t</div>\n  </td>\n  <td>\n    <div class="control-group">\n  \t\t<div class="controls input-append">\n  \t\t\t<input type="text" maxlength="6" class="span1" value="' +
((__t = ( square_feet )) == null ? '' : __t) +
'">\n  \t\t\t<div class="add-on">' +
((__t = ( i18nUnit.form.squarefeetsymbol )) == null ? '' : __t) +
'</div>\n  \t\t</div>\n  \t</div>\n  </td>\n  <td>\n    <div class="control-group">\n  \t\t<div class="controls">\n        <textarea class="span3">' +
((__t = ( description )) == null ? '' : __t) +
'</textarea>\n  \t\t</div>\n  \t</div>\n  </td>\n  <td>\n    <a class="btn" href="unit/' +
((__t = ( objectId )) == null ? '' : __t) +
'/add/lease">' +
((__t = ( i18nUnit.actions.add_lease )) == null ? '' : __t) +
'</a>\n    <button class="btn btn-mini btn-danger delete">' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'</button>\n  </td>\n</tr>';

}
return __p
};

  return this["JST"];
});