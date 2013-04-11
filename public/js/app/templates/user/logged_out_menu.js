define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/logged_out_menu.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<li id="login-nav" class="auth-nav dropdown">\n  <a id="lLabel" data-toggle="dropdown" href="#" role="button" class="dropdown-toggle">\n    ' +
((__t = ( i18nDevise.actions.login )) == null ? '' : __t) +
'\n  </a>\n  <div aria-labelledby="lLabel" class="dropdown-menu pull-right">\n    <button class="btn-facebook btn-block">' +
((__t = ( i18nDevise.actions.sign_in_with("Facebook") )) == null ? '' : __t) +
'</button>\n    <hr>\n    <form class="login-form form-inline">\n      <div class="alert alert-error" style="display:none"></div>        \n      <fieldset class="auth-email">\n        <legend>' +
((__t = ( i18nDevise.actions.sign_in_with("Email") )) == null ? '' : __t) +
'</legend>\n        <div class="control-group username-group">\n          <label for="login-username" class="control-label element-invisible">' +
((__t = ( i18nDevise.form.email )) == null ? '' : __t) +
':</label>\n          <div class="controls">\n            <input type="email" name="login-username" id="login-username" class="span" size="28" placeholder="' +
((__t = ( i18nDevise.form.email )) == null ? '' : __t) +
'">\n          </div>\n        </div>\n        <div class="control-group password-group">\n          <label for="login-password" class="control-label element-invisible">' +
((__t = ( i18nDevise.form.password )) == null ? '' : __t) +
':</label>\n          <div class="controls">\n            <input type="password" name="password" id="login-password" class="span" size="28" placeholder="' +
((__t = ( i18nDevise.form.password )) == null ? '' : __t) +
'">\n          </div>\n        </div>\n        <button class="btn btn-block">' +
((__t = ( i18nDevise.actions.login )) == null ? '' : __t) +
'</button>\n        <small><a class="reset-password-modal" href="#">' +
((__t = ( i18nDevise.actions.forgot_your_password )) == null ? '' : __t) +
'</a></small>\n      </fieldset>\n    </form>\n  </div>\n</li>\n<li id="signup-nav" class="auth-nav dropdown">\n  <a id="sLabel" data-toggle="dropdown" href="#" role="button" class="dropdown-toggle">\n    ' +
((__t = ( i18nDevise.actions.signup )) == null ? '' : __t) +
'\n  </a>\n  <div aria-labelledby="sLabel" class="dropdown-menu pull-right">\n    <button class="btn-facebook btn-block">' +
((__t = ( i18nDevise.actions.sign_in_with("Facebook") )) == null ? '' : __t) +
'</button>\n    <hr>\n    <form class="signup-form form-inline">\n      <div class="alert alert-error" style="display:none"></div>\n      <fieldset class="auth-email">\n        <legend>' +
((__t = ( i18nDevise.actions.sign_up_with("Email") )) == null ? '' : __t) +
'</legend>\n        <div class="control-group username-group">\n          <label for="email" class="control-label element-invisible">' +
((__t = ( i18nDevise.form.email )) == null ? '' : __t) +
':</label>\n          <div class="controls">\n            <input type="email" name="email" id="signup-username" class="span" size="28" placeholder="' +
((__t = ( i18nDevise.form.email )) == null ? '' : __t) +
'">\n          </div>\n        </div>\n        <div class="control-group password-group">\n          <label for="password" class="control-label element-invisible">' +
((__t = ( i18nDevise.form.password )) == null ? '' : __t) +
':</label>\n          <div class="controls">\n            <input type="password" name="password" id="signup-password" class="span" size="28" placeholder="' +
((__t = ( i18nDevise.form.password )) == null ? '' : __t) +
'">\n          </div>\n        </div>\n        <div class="control-group type-group">\n          <label for="type" class="control-label">' +
((__t = ( i18nDevise.form.type.label )) == null ? '' : __t) +
':</label>\n          <div class="controls">\n            <div class="toggle">\n\t          <label class="toggle-radio" for="toggleOption1">' +
((__t = ( i18nDevise.form.type.tenant )) == null ? '' : __t) +
'</label>\n\t          <input type="radio" name="type" id="toggleOption1" value="tenant" checked="checked">\n\t          <input type="radio" name="type" id="toggleOption2" value="manager">\n\t          <label class="toggle-radio" for="toggleOption2">' +
((__t = ( i18nDevise.form.type.manager )) == null ? '' : __t) +
'</label>\n\t        </div>\n          </div>\n        </div>\n        <button class="btn btn-block">' +
((__t = ( i18nDevise.actions.signup )) == null ? '' : __t) +
'</button>\n      </fieldset>\n    </form>\n  </div>\n</li>';

}
return __p
};

  return this["JST"];
});