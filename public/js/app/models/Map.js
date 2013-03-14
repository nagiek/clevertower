(function() {

  define(["jquery", "underscore", "backbone", "gmaps"], function($, _, Parse) {
    var Map;
    return Map = Parse.Object.extend("Map", {
      initialize: function(attrs) {
        var opts;
        this.geocoder = new google.maps.Geocoder();
        this.marker = attrs.marker;
        opts = {
          zoom: 2,
          center: this.GPoint(this.marker.get("center")),
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        return this.set({
          "point_exists": false,
          "opts": opts
        });
      },
      GPoint: function(GeoPoint) {
        return new google.maps.LatLng(GeoPoint._latitude, GeoPoint._longitude);
      },
      geocode: function(inputHash) {
        var _this = this;
        return this.geocoder.geocode(inputHash, function(results, status) {
          if (status === google.maps.GeocoderStatus.OK) {
            _this.marker.set(_this.parse(results[0]));
            if (!_this.get("point_exists")) {
              _this.set("point_exists", true);
              return _this.trigger("marker:add", _this.marker);
            }
          } else {
            return alert("Geocoding failed: " + status);
          }
        });
      },
      parse: function(res) {
        var components, route, street_number;
        components = {
          'formatted_address': res.formatted_address,
          'center': new Parse.GeoPoint(res.geometry.location.lat(), res.geometry.location.lng()),
          'location_type': res.geometry.location_type
        };
        street_number = '';
        route = '';
        _.each(res.address_components, function(c) {
          var neighborhood;
          switch (c.types[0]) {
            case 'street_number':
              street_number = c.long_name;
              break;
            case 'route':
              route = c.long_name;
              break;
            case 'locality':
              components.locality = c.long_name;
              break;
            case 'neighborhood':
              neighborhood = c.long_name;
              break;
            case 'administrative_area_level_1':
              components.administrative_area_level_1 = c.short_name.substr(0, 2).toUpperCase();
              break;
            case 'administrative_area_level_2':
              components.administrative_area_level_2 = c.short_name.substr(0, 2).toUpperCase();
              break;
            case 'country':
              components.country = c.short_name.substr(0, 2).toUpperCase();
              break;
            case 'postal_code':
              components.postal_code = c.long_name;
              break;
          }
        });
        components.thoroughfare = street_number + " " + route;
        return components;
      },
      geolocate: function(e) {
        var _this = this;
        if (navigator.geolocation) {
          return navigator.geolocation.getCurrentPosition(function(position) {
            _this.marker.set("center", new Parse.GeoPoint(position.coords));
            return _this.geocode({
              latLng: _this.GPoint(_this.marker.get("center"))
            });
          });
        } else if (google.loader.ClientLocation) {
          this.marker.set("center", new Parse.GeoPoint(google.loader.ClientLocation));
          return this.geocode({
            latLng: this.GPoint(this.marker.get("center"))
          });
        } else {
          this.marker.set("center", new Parse.GeoPoint());
          alert(i18nProperty.errors.no_geolocaiton);
          return this.geocode({
            latLng: this.GPoint(this.marker.get("center"))
          });
        }
      }
    });
  });

}).call(this);
