define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/summary.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<div class="property views-row row">\n  <div class="views-field-title span8">\n    <div class="photo photo-profile">\n      <a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'">\n        <img src="' +
((__t = ( cover )) == null ? '' : __t) +
'" alt="Profile" class="profile-picture">\n      </a>\n    </div>\n      \n    <div class="btn-toolbar stay-right">\n      ';
 if (init !== false) { ;
__p += '\n        <div class="btn-group">\n          <a href="#" class="btn btn-warning">\n            <i class="icon icon-lightning"></i>\n          </a>\n        </div>\n      ';
 } ;
__p += '\n      ' +
((__t = ( JST["src/js/templates/property/menu.jst"]({objectId: objectId, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n    </div>\n    \n    <div class="profile-float">\n      <h3><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( title )) == null ? '' : __t) +
'</a></h3>\n    </div>\n    \n    <dl class="profile-float">\n      <!-- <div class="span"> -->\n        <dt><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/tasks">' +
((__t = ( i18nCommon.classes.tasks )) == null ? '' : __t) +
'</a></dt>\n        <dd>' +
((__t = ( tasks )) == null ? '' : __t) +
'</dd>\n      <!-- </div> -->\n      <!-- <div class="span"> -->\n        <dt><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/finance">' +
((__t = ( i18nCommon.classes.finances )) == null ? '' : __t) +
'</a></dt>\n        <dd>\n          <span class="incomes">' +
((__t = ( incomes )) == null ? '' : __t) +
'</span>\n          <span class="expenses">' +
((__t = ( expenses )) == null ? '' : __t) +
'</span>\n        </dd>\n      <!-- </div> -->\n      <!-- <div class="span"> -->\n        <dt><a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'/tasks">' +
((__t = ( i18nProperty.structure.vacancies )) == null ? '' : __t) +
'</a></dt>\n        <dd>' +
((__t = ( vacant_units )) == null ? '' : __t) +
' ' +
((__t = ( i18nCommon.prepositions.of )) == null ? '' : __t) +
' ' +
((__t = ( units )) == null ? '' : __t) +
'</dd>\n      <!-- </div> -->\n    </dl>\n  </div>\n</div>';

}
return __p
};

  return this["JST"];
});