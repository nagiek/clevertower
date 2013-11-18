this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/new/map.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<p class="help-general text-center">\n  ';
 if (forNetwork) { ;
__p +=
((__t = ( i18nProperty.search.map_instructions_mgr )) == null ? '' : __t) +
'\n  ';
 } else { ;
__p +=
((__t = ( i18nProperty.search.map_instructions_tnt )) == null ? '' : __t);
 } ;
__p += '\n</p>\n<div id="address-search-group" class="form-group form-inline form-condensed">\n  <div class="row">\n    <div class="col-xs-9 col-sm-6 col-sm-offset-2">\n      <div class="input-group">\n        <input type="text" name="search" id="geolocation-search" class="form-control input-lg" placeholder="' +
((__t = ( i18nProperty.actions.search )) == null ? '' : __t) +
'">\n        <span class="input-group-btn">\n          <button class="search btn btn-info btn-lg">\n            <span class="glyphicon glyphicon-search"></span>\n          </button>\n        </span>\n      </div>\n    </div>\n    <div class="col-xs-3 col-sm-2 text-right">\n      <button type="button" class="geolocate btn btn-default btn-lg" style="display:none;">\n        <span class="glyphicon glyphicon-map-marker"></span>\n        <span class="hidden-xs">' +
((__t = ( i18nProperty.actions.geolocate )) == null ? '' : __t) +
'</span>\n      </button>\n    </div>\n  </div>\n</div>\n\n<div class="row">\n  <div class="map_container col-sm-8 right-md right-lg">\n    <div id="mapCanvas" class="map"></div>\n  </div>\n  <div class="col-sm-4">\n    <ul id="property-search-results" class="search-results list-unstyled">\n      <li class="empty text-center font-large">' +
((__t = ( i18nProperty.search.awaiting_search )) == null ? '' : __t) +
'</li>\n    </ul>\n    <p class="help-block">' +
((__t = ( i18nProperty.search.private_property )) == null ? '' : __t) +
'</p>\n  </div>\n</div>';

}
return __p
};