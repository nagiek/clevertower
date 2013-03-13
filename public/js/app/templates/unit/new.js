define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/unit/new.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<td class="title-group">\n  <div class="control-group">\n\t\t<div class="controls">\n\t\t\t<input type="text" maxlength="6" name="title" class="span1" value="' +
((__t = ( title )) == null ? '' : __t) +
'">\n\t\t</div>\n\t</div>\n</td>\n<td><span class="label label-warning">' +
((__t = ( i18nCommon.adjectives.unsaved )) == null ? '' : __t) +
'</span></td>\n<td>\n  <div class="control-group">\n\t\t<div class="controls">\n\t\t\t<select name="bedrooms">\n\t\t\t  <option value="0" ' +
((__t = ( bedrooms == 0 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.zero )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="1" ' +
((__t = ( bedrooms == 1 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.one )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="2" ' +
((__t = ( bedrooms == 2 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.two )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="3" ' +
((__t = ( bedrooms == 3 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.three )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="4" ' +
((__t = ( bedrooms == 4 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.four )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="5" ' +
((__t = ( bedrooms == 5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.five )) == null ? '' : __t) +
'</option>\n\t\t\t</select>\n\t\t</div>\n\t</div>\n</td>\n<td>\n  <div class="control-group">\n\t\t<div class="controls">\n\t\t\t<select name="bathrooms">\n\t\t\t  <option value="0" ' +
((__t = ( bathrooms == 0 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.zero )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="1" ' +
((__t = ( bathrooms == 1 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.one )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="1.5" ' +
((__t = ( bathrooms == 1.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.oneandahalf )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="2" ' +
((__t = ( bathrooms == 2 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.two )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="2.5" ' +
((__t = ( bathrooms == 2.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.twoandahalf )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="3" ' +
((__t = ( bathrooms == 3 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.three )) == null ? '' : __t) +
'</option>\n\t\t\t  <option value="3.5" ' +
((__t = ( bathrooms == 3.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.threeandahalf )) == null ? '' : __t) +
'</option>\n\t\t\t</select>\n\t\t</div>\n\t</div>\n</td>\n<td>\n  <div class="control-group">\n\t\t<div class="controls input-append">\n\t\t\t<input type="text" maxlength="6" class="span1" name="square_feet" value="' +
((__t = ( square_feet )) == null ? '' : __t) +
'">\n\t\t\t<div class="add-on">' +
((__t = ( i18nUnit.form.squarefeetsymbol )) == null ? '' : __t) +
'</div>\n\t\t</div>\n\t</div>\n</td>\n<td>\n  <div class="control-group">\n\t\t<div class="controls">\n      <textarea name="description" class="span3">' +
((__t = ( description )) == null ? '' : __t) +
'</textarea>\n\t\t</div>\n\t</div>\n</td>\n<td>\n  <button class="btn btn-mini btn-danger remove">' +
((__t = ( i18nCommon.actions.remove )) == null ? '' : __t) +
'</button>\n</td>';

}
return __p
};

  return this["JST"];
});