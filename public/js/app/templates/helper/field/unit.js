this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/helper/field/unit.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 if (unit) { ;
__p += '\n  <div class="row">\n    <div class="form-group col-sm-4">\n      <label for="unit[attributes][title]" class="control-label">' +
((__t = ( i18nCommon.classes.Unit )) == null ? '' : __t);
 if (required) { ;
__p += ' <span class="required">*</span>';
 } ;
__p += '</label>\n      <input type="text" name="unit[attributes][title]" placeholder="' +
((__t = ( i18nUnit.form.unit_number )) == null ? '' : __t) +
'" class="form-control new-unit" maxlength="16" value="' +
((__t = ( unit.title )) == null ? '' : __t) +
'">\n    </div>\n    <div class="form-group col-sm-4">\n      <label for="unit[attributes][bedrooms]" class="control-label">' +
((__t = ( i18nUnit.fields.bedrooms )) == null ? '' : __t);
 if (required) { ;
__p += ' <span class="required">*</span>';
 } ;
__p += '</label>\n      <select class="form-control" name="unit[attributes][bedrooms]">\n          <option value="0" ' +
((__t = ( unit.bedrooms == 0 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.zero )) == null ? '' : __t) +
'</option>\n          <option value="1" ' +
((__t = ( unit.bedrooms == 1 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.one )) == null ? '' : __t) +
'</option>\n          <option value="2" ' +
((__t = ( unit.bedrooms == 2 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.two )) == null ? '' : __t) +
'</option>\n          <option value="3" ' +
((__t = ( unit.bedrooms == 3 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.three )) == null ? '' : __t) +
'</option>\n          <option value="4" ' +
((__t = ( unit.bedrooms == 4 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.four )) == null ? '' : __t) +
'</option>\n          <option value="5" ' +
((__t = ( unit.bedrooms == 5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bedrooms.five )) == null ? '' : __t) +
'</option>\n        </select>\n    </div>\n    <div class="form-group col-sm-4">\n      <label for="unit[attributes][bathrooms]" class="control-label">' +
((__t = ( i18nUnit.fields.bathrooms )) == null ? '' : __t);
 if (required) { ;
__p += ' <span class="required">*</span>';
 } ;
__p += '</label>\n      <select class="form-control" name="unit[attributes][bathrooms]">\n        <option value="0" ' +
((__t = ( unit.bathrooms == 0 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.zero )) == null ? '' : __t) +
'</option>\n        <option value="1" ' +
((__t = ( unit.bathrooms == 1 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.one )) == null ? '' : __t) +
'</option>\n        <option value="1.5" ' +
((__t = ( unit.bathrooms == 1.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.oneandahalf )) == null ? '' : __t) +
'</option>\n        <option value="2" ' +
((__t = ( unit.bathrooms == 2 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.two )) == null ? '' : __t) +
'</option>\n        <option value="2.5" ' +
((__t = ( unit.bathrooms == 2.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.twoandahalf )) == null ? '' : __t) +
'</option>\n        <option value="3" ' +
((__t = ( unit.bathrooms == 3 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.three )) == null ? '' : __t) +
'</option>\n        <option value="3.5" ' +
((__t = ( unit.bathrooms == 3.5 ? 'selected' : '' )) == null ? '' : __t) +
'>' +
((__t = ( i18nUnit.form.bathrooms.threeandahalf )) == null ? '' : __t) +
'</option>\n      </select>\n    </div>\n  </div>\n';
 } else { ;
__p += '\n  <div class="unit-group form-group">\n    <label for="unit-select" class="control-label';
 if (horiz) { ;
__p += ' col-sm-2';
 } ;
__p += '">' +
((__t = ( i18nCommon.classes.Unit )) == null ? '' : __t);
 if (required) { ;
__p += ' <span class="required">*</span>';
 } ;
__p += '</label>\n    ';
 if (!horiz) { ;
__p += '<div class="row">';
 } ;
__p += '\n    <div class="col-xs-6';
 if (horiz) { ;
__p += ' col-sm-3';
 } ;
__p += '">\n      <select name="unit[id]" class="form-control unit-select" required="' +
((__t = ( required )) == null ? '' : __t) +
'">\n        <option value="">' +
((__t = ( i18nCommon.form.select.select_value )) == null ? '' : __t) +
'</option>\n      </select>\n    </div>\n    <div class="col-xs-6';
 if (horiz) { ;
__p += ' col-sm-2';
 } ;
__p += '">\n      <input type="text" name="unit[attributes][title]" placeholder="' +
((__t = ( i18nUnit.form.unit_number )) == null ? '' : __t) +
'" class="form-control new-unit" maxlength="16" style="display:none;">\n    </div>\n    ';
 if (!horiz) { ;
__p += '</div>';
 } ;
__p += '\n    ';
 if (help) { ;
__p += '\n      <p class="help-block col-sm-offset-2 col-sm-10">\n        <span class="label label-default label-large">' +
((__t = ( i18nCommon.adjectives.private )) == null ? '' : __t) +
'</span>\n        ' +
((__t = ( i18nUnit.form.help )) == null ? '' : __t) +
'\n      </p>\n    ';
 } ;
__p += '\n  </div>\n  <input type="hidden" name="unit[__type]" value="Pointer">\n  <input type="hidden" name="unit[className]" value="Unit">\n';
 } ;


}
return __p
};