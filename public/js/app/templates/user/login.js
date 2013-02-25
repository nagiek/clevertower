define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/login.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<a id="lLabel" data-toggle="dropdown" href="#" role="button" class="dropdown-toggle">\n  Login\n</a>\n<div aria-labelledby="lLabel" class="dropdown-menu pull-right">\n  <form class="login-form form-inline">\n    <div class="error" style="display:none"></div>\n    <div class="control-group">\n      <label for="login-username" class="control-label hide">Email:</label>\n      <div class="controls">\n        <input type="email" name="login-username" id="login-username" class="span" size="22" placeholder="Email">\n      </div>\n    </div>\n    <div class="control-group">\n      <label for="login-password" class="control-label hide">Password:</label>\n      <div class="controls">\n        <input type="password" name="password" id="login-password" class="span" size="22" placeholder="Password">\n      </div>\n    </div>\n    <button class="btn btn-block">Log In</button>\n  </form>\n</div>';

}
return __p
};

  return this["JST"];
});