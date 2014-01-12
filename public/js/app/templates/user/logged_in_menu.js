this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/user/logged_in_menu.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<li class="hidden-sm hidden-xs">\n  <a id="profile-link" class="clearfix" href="/users/' +
((__t = ( objectId )) == null ? '' : __t) +
'">\n    <img src="' +
((__t = ( src )) == null ? '' : __t) +
'" class="pull-left photo photo-tiny img-circle" alt="' +
((__t = ( photo_alt )) == null ? '' : __t) +
'" width="32" height="32">\n    <span class="photo-float tiny-float">' +
((__t = ( name )) == null ? '' : __t) +
'</span>\n  </a>\n</li>\n<li id="memos" class="dropdown list-item-icon">\n  <a id="mLabel" data-target="#" data-toggle="dropdown" role="menu" class="dropdown-toggle">\n    <span class="glyphicon glyphicon-flag"></span>\n    <span id="memos-count" class="badge badge-danger hide">0</span>\n  </a>\n  <div aria-labelledby="mLabel" role="menu" class="dropdown-menu notifications-menu">\n    <ul></ul>\n    <a href="/notifications" class="dropdown-bottom">' +
((__t = ( i18nCommon.expressions.see_all )) == null ? '' : __t) +
'</a>\n  </div>\n</li>\n<li id="friend-requests" class="dropdown list-item-icon">\n  <a id="fLabel" data-target="#" data-toggle="dropdown" role="menu" class="dropdown-toggle">\n    <span class="glyphicon glyphicon-user"></span>\n    <span id="friend-requests-count" class="badge badge-danger hide">0</span>\n  </a>\n  <div aria-labelledby="fLabel" role="menu" class="dropdown-menu notifications-menu">\n    <ul></ul>\n    <a href="/notifications" class="dropdown-bottom">' +
((__t = ( i18nCommon.expressions.see_all )) == null ? '' : __t) +
'</a>\n  </div>\n</li>\n<li class="dropdown hidden-sm hidden-xs list-item-icon">\n  <a id="pLabel" data-target="#" data-toggle="dropdown" role="menu" class="dropdown-toggle">\n    <span class="glyphicon glyphicon-cog"></span>\n  </a>\n  <ul aria-labelledby="pLabel" role="menu" class="dropdown-menu">\n    <li><a href="/account/building"><span class="glyphicon glyphicon-home glyphicon-building"></span> ' +
((__t = ( i18nCommon.nouns.building )) == null ? '' : __t) +
'</a></li>\n    <li><a href="/account/history"><span class="glyphicon glyphicon-file"></span> ' +
((__t = ( i18nCommon.nouns.history )) == null ? '' : __t) +
'</a></li>\n    <li class="divider">\n    <li><a href="/account/settings"><span class="glyphicon glyphicon-user"></span> ' +
((__t = ( i18nUser.menu.account_settings )) == null ? '' : __t) +
'</a></li>\n    <li><a href="/account/privacy"><span class="glyphicon glyphicon-lock"></span> ' +
((__t = ( i18nUser.menu.privacy_settings )) == null ? '' : __t) +
'</a></li>\n    <li><a href="/account/apps"><span class="glyphicon glyphicon-th"></span> ' +
((__t = ( i18nUser.menu.apps )) == null ? '' : __t) +
'</a></li>\n    <li class="divider">\n    <li><a href="/find_friends"><span class="glyphicon glyphicon-info-sign"></span> ' +
((__t = ( i18nUser.menu.find_friends )) == null ? '' : __t) +
'</a></li>\n    <li class="divider">\n    <li><a id="logout" href="#">' +
((__t = ( i18nDevise.actions.logout )) == null ? '' : __t) +
'</a></li>\n  </ul>\n</li>\n<li class="visible-xs visible-sm list-item-icon"><a href="#" data-target="#search-menu" data-toggle="collapse"><span class="glyphicon glyphicon-search"></span></a></li>';

}
return __p
};