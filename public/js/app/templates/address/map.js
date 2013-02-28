define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/address/map.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<form class="address-form">\n  <div class="alert alert-error" style="display:none"></div>\n  <div id="address-search-group" class="control-group">\n    <div class="controls">\n      <div class="input-append inline-block">\n        <input type="text" name="search" id="geolocation-search" class="span6" placeholder="' +
((__t = ( i18nAddress.actions.search )) == null ? '' : __t) +
'">\n        <button class="search btn btn-info">\n          <i class="icon icon-white icon-search"></i>\n        </button>\n      </div>\n      <a class="geolocate btn inline-block" href="#" style="display:none;">\n        <i class="icon icon-map-marker"></i>\n        <span class="text">' +
((__t = ( i18nAddress.actions.geolocate )) == null ? '' : __t) +
'</span>\n      </a>\n    </div>\n  </div>\n  \n  <div class="map_container">\n    <div id="mapCanvas" class="map">\n  </div>\n\n  <input type="hidden" id="address_components">\n  <input type="hidden" id="address_location_type">\n  <input type="hidden" id="address_lat">\n  <input type="hidden" id="address_lng">\n  <input type="hidden" id="address_thoroughfare">\n  <input type="hidden" id="address_locality">\n  <input type="hidden" id="address_neighbourhood">\n  <input type="hidden" id="address_administrative_area_level_1">\n  <input type="hidden" id="address_administrative_area_level_2">\n  <input type="hidden" id="address_country">\n  <input type="hidden" id="address_postal_code">\n\n</form>';

}
return __p
};

  return this["JST"];
});