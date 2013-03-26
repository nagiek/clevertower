define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/signup.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<a id="sLabel" data-toggle="dropdown" href="#" role="button" class="dropdown-toggle">\n  ' +
((__t = ( i18nDevise.actions.signup )) == null ? '' : __t) +
'\n</a>\n<div aria-labelledby="sLabel" class="dropdown-menu pull-right">\n  <form class="signup-form form-inline">\n    <div class="alert alert-error" style="display:none"></div>\n    <div class="control-group username-group">\n      <label for="email" class="control-label element-invisible">' +
((__t = ( i18nDevise.form.email )) == null ? '' : __t) +
':</label>\n      <div class="controls">\n        <input type="email" name="email" id="signup-username" class="span" size="22" placeholder="' +
((__t = ( i18nDevise.form.email )) == null ? '' : __t) +
'">\n      </div>\n    </div>\n    <div class="control-group password-group">\n      <label for="password" class="control-label element-invisible">' +
((__t = ( i18nDevise.form.password )) == null ? '' : __t) +
':</label>\n      <div class="controls">\n        <input type="password" name="password" id="signup-password" class="span" size="22" placeholder="' +
((__t = ( i18nDevise.form.password )) == null ? '' : __t) +
'">\n      </div>\n    </div>\n    <button class="btn btn-block">' +
((__t = ( i18nDevise.actions.signup )) == null ? '' : __t) +
'</button>\n    <small><a href="/user/reset/password">' +
((__t = ( i18nDevise.actions.forgot_your_password )) == null ? '' : __t) +
'</a></small>\n  </form>\n</div>';

}
return __p
};

  return this["JST"];
});