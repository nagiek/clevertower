define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/logged_in_menu.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<li><a id="profile-link" href="/users/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( name )) == null ? '' : __t) +
'</a></li>\n<li id="notifications" class="dropdown">\n  <a id="nLabel" data-target="#" data-toggle="dropdown" role="menu" class="dropdown-toggle">\n    <i class="icon icon-flag"></i>\n    <span id="notifications-count" class="badge">0</span>\n  </a>\n  <ul aria-labelledby="nLabel" role="menu" class="dropdown-menu pull-right"></ul>\n</li>\n<li class="dropdown">\n  <a id="pLabel" data-target="#" data-toggle="dropdown" role="menu" class="dropdown-toggle">\n    <i class="icon icon-cog"></i>\n  </a>\n  <ul aria-labelledby="pLabel" role="menu" class="dropdown-menu pull-right">\n    <li><a href="/account/settings">' +
((__t = ( i18nUser.menu.edit_account )) == null ? '' : __t) +
'</a></li>\n    <li><a href="/account/privacy">' +
((__t = ( i18nUser.menu.edit_privacy )) == null ? '' : __t) +
'</a></li>\n    <li class="divider">\n    <li><a id="logout" href="#">' +
((__t = ( i18nDevise.actions.logout )) == null ? '' : __t) +
'</a></li>\n  </ul>\n</li>';

}
return __p
};

  return this["JST"];
});