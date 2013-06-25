this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/summary.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div class="property span8">\n  <div class="photo photo-medium photo-elastic pull-left tablet-left">\n    <a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'">\n      <img src="' +
((__t = ( cover )) == null ? '' : __t) +
'" alt="Profile" class="profile-picture">\n    </a>\n  </div>\n  \n  <div class="photo-float medium-float elastic-float">\n    <div class="btn-toolbar stay-right">\n      <div class="btn-group">\n        <a href="#" class="btn btn-small dropdown-toggle" rel="tooltip" data-toggle="dropdown" data-original-title="' +
((__t = ( i18nProperty.menu.day_to_day )) == null ? '' : __t) +
'">\n          <i class="icon icon-eye-open"></i>\n          <b class="caret"></b>\n        </a>\n        <h4 class="element-invisible">' +
((__t = ( i18nProperty.menu.day_to_day )) == null ? '' : __t) +
'</h4>\n        ' +
((__t = ( JST["src/js/templates/property/menu/show.jst"]({baseUrl: baseUrl, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n      </div>\n\n      <div class="btn-group">\n        <a href="#" class="btn btn-small dropdown-toggle" rel="tooltip" data-toggle="dropdown" data-original-title="' +
((__t = ( i18nProperty.menu.building )) == null ? '' : __t) +
'">\n          <i class="icon icon-building"></i>\n          <b class="caret"></b>\n        </a>\n        <h4 class="element-invisible">' +
((__t = ( i18nProperty.menu.building )) == null ? '' : __t) +
'</h4>\n        ' +
((__t = ( JST["src/js/templates/property/menu/building.jst"]({publicUrl: publicUrl, baseUrl: baseUrl, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n      </div>\n      <!--\n      <div class="btn-group">\n        <a href="#" class="btn btn-small dropdown-toggle" rel="tooltip" data-toggle="dropdown" data-original-title="' +
((__t = ( i18nProperty.menu.reports )) == null ? '' : __t) +
'">\n          <i class="icon icon-file"></i>\n          <b class="caret"></b>\n        </a>\n        <h4 class="element-invisible">' +
((__t = ( i18nProperty.menu.reports )) == null ? '' : __t) +
'</h4>\n        ' +
((__t = ( JST["src/js/templates/property/menu/reports.jst"]({baseUrl: baseUrl, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n      </div>\n\n      <div class="btn-group">\n        <a href="#" class="btn btn-small btn-success dropdown-toggle" rel="tooltip" data-toggle="dropdown" data-original-title="' +
((__t = ( i18nProperty.menu.actions )) == null ? '' : __t) +
'">\n          <i class="icon icon-plus icon-white"></i>\n          <b class="caret"></b>\n        </a>\n        <h4 class="element-invisible">' +
((__t = ( i18nProperty.menu.actions )) == null ? '' : __t) +
'</h4>\n        ' +
((__t = ( JST["src/js/templates/property/menu/actions.jst"]({baseUrl: baseUrl, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n      </div>\n       -->\n    </div>\n    \n    <h2>\n      <a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( title )) == null ? '' : __t) +
'</a>\n      ';
 if (init !== false) { ;
__p += '\n        <a href="#" class="badge badge-info" rel="tooltip" data-original-title="' +
((__t = (i18nProperty.actions.setup_property)) == null ? '' : __t) +
'">\n          <i class="icon icon-lightning icon-white"></i>\n        </a>\n      ';
 } ;
__p += '\n    </h2>\n    \n    <dl>\n      <!-- <div class="span"> -->\n        <dt><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/listings">' +
((__t = ( i18nCommon.classes.listings )) == null ? '' : __t) +
'</a></dt>\n        <dd>' +
((__t = ( listings )) == null ? '' : __t) +
'</dd>\n      <!-- </div> -->\n      <!-- <div class="span"> -->\n<!--         <dt><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/finance">' +
((__t = ( i18nCommon.classes.finances )) == null ? '' : __t) +
'</a></dt>\n        <dd>\n          <span class="incomes">' +
((__t = ( incomes )) == null ? '' : __t) +
'</span>\n          <span class="expenses">' +
((__t = ( expenses )) == null ? '' : __t) +
'</span>\n        </dd> -->\n      <!-- </div> -->\n      <!-- <div class="span"> -->\n        <dt><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/listings">' +
((__t = ( i18nProperty.structure.vacancies )) == null ? '' : __t) +
'</a></dt>\n        <dd>' +
((__t = ( vacant_units )) == null ? '' : __t) +
' ' +
((__t = ( i18nCommon.prepositions.of )) == null ? '' : __t) +
' ' +
((__t = ( unitsLength )) == null ? '' : __t) +
'</dd>\n      <!-- </div> -->\n    </dl>\n  </div>\n</div>';

}
return __p
};