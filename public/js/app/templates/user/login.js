define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/login.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<a id="lLabel" data-toggle="dropdown" href="#" role="button" class="dropdown-toggle">\n  ' +
((__t = ( i18nDevise.actions.login )) == null ? '' : __t) +
'\n</a>\n<div aria-labelledby="lLabel" class="dropdown-menu pull-right">\n  <form class="login-form form-inline">\n    <div class="alert alert-error" style="display:none"></div>\n    <div class="control-group username-group">\n      <label for="login-username" class="control-label element-invisible">' +
((__t = ( i18nDevise.form.email )) == null ? '' : __t) +
':</label>\n      <div class="controls">\n        <input type="email" name="login-username" id="login-username" class="span" size="22" placeholder="' +
((__t = ( i18nDevise.form.email )) == null ? '' : __t) +
'">\n      </div>\n    </div>\n    <div class="control-group password-group">\n      <label for="login-password" class="control-label element-invisible">' +
((__t = ( i18nDevise.form.password )) == null ? '' : __t) +
':</label>\n      <div class="controls">\n        <input type="password" name="password" id="login-password" class="span" size="22" placeholder="' +
((__t = ( i18nDevise.form.password )) == null ? '' : __t) +
'">\n      </div>\n    </div>\n    <button class="btn btn-block">' +
((__t = ( i18nDevise.actions.login )) == null ? '' : __t) +
'</button>\n    <small><a href="/user/reset/password">' +
((__t = ( i18nDevise.actions.forgot_your_password )) == null ? '' : __t) +
'</a></small>\n  </form>\n</div>';

}
return __p
};

  return this["JST"];
});