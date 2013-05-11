define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/logged_out_menu.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<li><a id="login-link" href="#">' +
((__t = ( i18nDevise.actions.login )) == null ? '' : __t) +
'</a></li>\n<li><a id="signup-link" href="#">' +
((__t = ( i18nDevise.actions.signup )) == null ? '' : __t) +
'</a></li>';

}
return __p
};

  return this["JST"];
});