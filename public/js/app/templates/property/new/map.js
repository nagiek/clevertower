this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/new/map.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<p class="help-general text-center">' +
((__t = ( i18nProperty.search.map_instructions )) == null ? '' : __t) +
'</p></div>\n<div id="address-search-group" class="control-group form-inline form-large text-center">\n  <div class="controls">\n    <div class="input-append inline-block">\n      <input type="text" name="search" id="geolocation-search" class="span5" placeholder="' +
((__t = ( i18nProperty.actions.search )) == null ? '' : __t) +
'">\n      <button class="search btn btn-info">\n        <i class="icon icon-white icon-search"></i>\n      </button>\n    </div>\n  </div>\n  <a class="geolocate btn inline-block" href="#" style="display:none;">\n    <i class="icon icon-map-marker"></i>\n    <span class="text">' +
((__t = ( i18nProperty.actions.geolocate )) == null ? '' : __t) +
'</span>\n  </a>\n</div>\n\n<div class="row">\n  <div class="map_container span8 pull-right">\n    <div id="mapCanvas" class="map"></div>\n  </div>\n  <div class="span4">\n    <ul id="search-results" class="unstyled">\n      <li class="empty text-center font-large">' +
((__t = ( i18nProperty.search.awaiting_search )) == null ? '' : __t) +
'</li>\n    </ul>\n  </div>\n</div>';

}
return __p
};