define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/helper/fields/tenant_field.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class="fieldset-wrapper accordion-inner">\n  <div class="form-item form-type-textarea form-item-users-emails control-group">\n    <label for="edit-users-emails" class="control-label">Enter the email addresses of\n    the people you wish to add.</label>\n\n    <div class="controls">\n      <div class="form-textarea-wrapper resizable">\n        <textarea id="edit-users-emails" name="users[emails]" cols="60" rows="2"\n        class="form-textarea">\n</textarea>\n      </div>\n\n      <p class="help-block">Enter a comma-separated list of email addresses.</p>\n    </div>\n  </div>\n</div>';

}
return __p
};

  return this["JST"];
});