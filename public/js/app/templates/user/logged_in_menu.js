define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/logged_in_menu.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 i18nDevise = require("i18n!nls/devise"); ;
__p += '\n\n<li><a id="profile" href="#">' +
((__t = ( Parse.User.current().get("username") )) == null ? '' : __t) +
'</a></li>\n<li class="dropdown">\n  <a id="pLabel" data-target="#" data-toggle="dropdown" href="/user_network_path" role="button" class="dropdown-toggle">\n    <i class="icon icon-cog"></i>\n  </a>\n  <ul aria-labelledby="pLabel" role="menu" class="dropdown-menu pull-right"></ul>\n</li>\n<li class="dropdown">\n  <a id="nLabel" data-target="#" data-toggle="dropdown" href="/user_notifications_path" role="button" class="dropdown-toggle">\n    <i class="icon icon-flag"></i>\n  </a>\n  <ul aria-labelledby="nLabel" role="menu" class="dropdown-menu pull-right"></ul>\n</li>\n<li><a id="logout" href="#">' +
((__t = ( i18nDevise.actions.logout )) == null ? '' : __t) +
'</a></li>';

}
return __p
};

  return this["JST"];
});