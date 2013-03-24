define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/helper/field/tenant.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class="row">\n  <div class="control-group span">\n    <label for="emails" class="control-label"></label>\n    <div class="controls">\n      <textarea name="emails" rows="2" class="span12"></textarea>\n      <p class="help-block">' +
((__t = ( i18nCommon.form.comma_separated )) == null ? '' : __t) +
'</p>\n    </div>\n  </div>\n</div>';

}
return __p
};

  return this["JST"];
});