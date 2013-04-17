define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/logged_in_menu.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<li>\n  <a id="profile-link" class="clearfix" href="/users/' +
((__t = ( objectId )) == null ? '' : __t) +
'">\n    <img src="' +
((__t = ( src )) == null ? '' : __t) +
'" class="stay-left photo photo-micro img-circle" alt="' +
((__t = ( photo_alt )) == null ? '' : __t) +
'" width="23" height="23">\n    <span class="photo-float micro-float">' +
((__t = ( name )) == null ? '' : __t) +
'</span>\n  </a>\n</li>\n<li id="notifications" class="dropdown">\n  <a id="nLabel" data-target="#" data-toggle="dropdown" role="menu" class="dropdown-toggle">\n    <i class="icon icon-flag"></i>\n    <span id="notifications-count" class="badge">0</span>\n  </a>\n  <ul aria-labelledby="nLabel" role="menu" class="dropdown-menu pull-right"></ul>\n</li>\n<li class="dropdown">\n  <a id="pLabel" data-target="#" data-toggle="dropdown" role="menu" class="dropdown-toggle">\n    <i class="icon icon-cog"></i>\n  </a>\n  <ul aria-labelledby="pLabel" role="menu" class="dropdown-menu pull-right">\n    <li><a href="/account/settings"><i class="icon icon-user"></i> ' +
((__t = ( i18nUser.menu.account_settings )) == null ? '' : __t) +
'</a></li>\n    <li><a href="/account/privacy"><i class="icon icon-lock"></i> ' +
((__t = ( i18nUser.menu.privacy_settings )) == null ? '' : __t) +
'</a></li>\n    <li><a href="/account/apps"><i class="icon icon-th"></i> ' +
((__t = ( i18nUser.menu.apps )) == null ? '' : __t) +
'</a></li>\n    <li class="divider">\n    <li><a id="logout" href="#">' +
((__t = ( i18nDevise.actions.logout )) == null ? '' : __t) +
'</a></li>\n  </ul>\n</li>';

}
return __p
};

  return this["JST"];
});