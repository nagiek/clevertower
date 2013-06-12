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
__p += '\n</p>\n</div>\n<div id="address-search-group" class="control-group form-inline form-large text-center">\n  <div class="controls">\n    <div class="input-append inline-block">\n      <input type="text" name="search" id="geolocation-search" class="span5" placeholder="' +
((__t = ( i18nProperty.actions.search )) == null ? '' : __t) +
'">\n      <button class="search btn btn-info">\n        <i class="icon icon-white icon-search"></i>\n      </button>\n    </div>\n  </div>\n  <a class="geolocate btn inline-block" href="#" style="display:none;">\n    <i class="icon icon-map-marker"></i>\n    <span class="text">' +
((__t = ( i18nProperty.actions.geolocate )) == null ? '' : __t) +
'</span>\n  </a>\n</div>\n\n<div class="row">\n  <div class="map_container span8 pull-right">\n    <div id="mapCanvas" class="map"></div>\n  </div>\n  <div class="span4">\n    <ul id="property-search-results" class="search-results unstyled">\n      <li class="empty text-center font-large">' +
((__t = ( i18nProperty.search.awaiting_search )) == null ? '' : __t) +
'</li>\n    </ul>\n    <p class="help-block">' +
((__t = ( i18nProperty.search.private_property )) == null ? '' : __t) +
'</p>\n  </div>\n</div>';

}
return __p
};