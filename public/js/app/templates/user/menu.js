define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/menu.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<ul id="user-menu" class="nav pull-right">\n  <li><a id="profile" href="#">' +
((__t = ( Parse.User.current().get("username") )) == null ? '' : __t) +
'</a></li>\n  <li class="dropdown">\n    <a id="pLabel" data-target="#" data-toggle="dropdown" href="/user_network_path" role="button" class="dropdown-toggle">\n      <i class="icon icon-cog"></i>\n    </a>\n    <ul aria-labelledby="pLabel" role="menu" class="dropdown-menu pull-right"></ul>\n  </li>\n  <li class="dropdown">\n    <a id="nLabel" data-target="#" data-toggle="dropdown" href="/user_notifications_path" role="button" class="dropdown-toggle">\n      <i class="icon icon-flag"></i>\n    </a>\n    <ul aria-labelledby="nLabel" role="menu" class="dropdown-menu pull-right"></ul>\n  </li>\n  <li><a id="logout" href="#">Logout</a></li>\n</ul>';

}
return __p
};

  return this["JST"];
});