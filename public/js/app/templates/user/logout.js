define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/logout.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div id="user-info">\n  Signed in as ' +
((__t = ( Parse.User.current().get("username") )) == null ? '' : __t) +
' (<a href="#" class="log-out">Log out</a>)\n</div>';

}
return __p
};

  return this["JST"];
});