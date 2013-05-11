define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/menu.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<!-- Day-to-day -->\n<div class="btn-group">\n  <a href="#" class="btn btn-small dropdown-toggle", data-toggle="dropdown" data-original-title ="' +
((__t = ( i18nProperty.menu.day_to_day )) == null ? '' : __t) +
'">\n    <i class="icon icon-eye"></i>\n    <b class="caret"></b>\n  </a>\n  <h4 class="element-invisible">' +
((__t = ( i18nProperty.menu.day_to_day )) == null ? '' : __t) +
'</h4>\n  ' +
((__t = ( JST["src/js/templates/property/menu/show.jst"]({objectId: objectId, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n</div>\n\n<div class="btn-group">\n  <a href="#" class="btn btn-small dropdown-toggle", data-toggle="dropdown" data-original-title ="' +
((__t = ( i18nProperty.menu.other )) == null ? '' : __t) +
'">\n    <i class="icon icon-ellipsis"></i>\n    <b class="caret"></b>\n  </a>\n  <h4 class="element-invisible">' +
((__t = ( i18nProperty.menu.building )) == null ? '' : __t) +
'</h4>\n  ' +
((__t = ( JST["src/js/templates/property/menu/building.jst"]({publicUrl: publicUrl, objectId: objectId, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n</div>\n\n<div class="btn-group">\n  <a href="#" class="btn btn-small dropdown-toggle", data-toggle="dropdown" data-original-title ="' +
((__t = ( i18nProperty.menu.v )) == null ? '' : __t) +
'">\n    <i class="icon icon-file"></i>\n    <b class="caret"></b>\n  </a>\n  <h4 class="element-invisible">' +
((__t = ( i18nProperty.menu.reports )) == null ? '' : __t) +
'</h4>\n  ' +
((__t = ( JST["src/js/templates/property/menu/reports.jst"]({objectId: objectId, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n</div>\n\n<div class="btn-group">\n  <a href="#" class="btn btn-small btn-success dropdown-toggle", data-toggle="dropdown" data-original-title ="' +
((__t = ( i18nProperty.menu.actions )) == null ? '' : __t) +
'">\n    <i class="icon icon-eye icon-white"></i>\n    <b class="caret"></b>\n  </a>\n  <h4 class="element-invisible">' +
((__t = ( i18nProperty.menu.actions )) == null ? '' : __t) +
'</h4>\n  ' +
((__t = ( JST["src/js/templates/property/menu/actions.jst"]({objectId: objectId, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n</div>';

}
return __p
};

  return this["JST"];
});