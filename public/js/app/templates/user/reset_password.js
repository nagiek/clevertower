define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/reset_password.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div id="reset-password-modal" class="modal form-modal hide fade">\n  <form id="reset-password-form" method="POST">\n    <div class="modal-header">\n      <button type="button" class="close" data-dismiss="modal" aria-labelledby="reset-password-modal-label" aria-hidden="true">&times;</button>\n      <h3 id="reset-password-modal-label">' +
((__t = ( i18nDevise.actions.forgot_your_password )) == null ? '' : __t) +
'</h3>\n    </div>\n    <div class="modal-body">\n      <div id="reset-email-group" class="control-group">\n        <label for="email" class="control-label element-invisible">' +
((__t = ( i18nDevise.form.email )) == null ? '' : __t) +
':</label>\n        <div class="controls">\n          <input type="email" name="email" id="reset-email" class="span input-tall input-block-level" size="22" placeholder="' +
((__t = ( i18nDevise.form.email )) == null ? '' : __t) +
'">\n          <p class="help-block">' +
((__t = ( i18nDevise.form.instructions_to_email )) == null ? '' : __t) +
'</p>\n        </div>\n      </div>\n    </div>\n    <div class="modal-footer">\n      <button class="reset-password btn btn-primary">' +
((__t = ( i18nDevise.actions.reset_password )) == null ? '' : __t) +
'</button>\n      <button class="btn" data-dismiss="modal">' +
((__t = ( i18nCommon.actions.close )) == null ? '' : __t) +
'</button>\n    </div>\n  </form>\n</div>';

}
return __p
};

  return this["JST"];
});