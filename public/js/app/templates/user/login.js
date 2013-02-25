define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/login.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<header id="header"></header>\n<div class="login">\n  <form class="login-form">\n    <h2>Log In</h2>\n    <div class="error" style="display:none"></div>\n    <input type="text" id="login-username" placeholder="Username" />\n    <input type="password" id="login-password" placeholder="Password" />\n    <button>Log In</button>\n  </form>\n\n  <form class="signup-form">\n    <h2>Sign Up</h2>\n    <div class="error" style="display:none"></div>\n    <input type="text" id="signup-username" placeholder="Username" />\n    <input type="password" id="signup-password" placeholder="Create a Password" />\n    <button>Sign Up</button>\n  </form>\n</div>';

}
return __p
};

  return this["JST"];
});