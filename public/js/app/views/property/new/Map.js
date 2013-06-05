(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "collections/PropertyResultsList", "views/property/Result", "views/helper/Alert", "i18n!nls/common", "i18n!nls/property", "templates/property/new/map", "gmaps"], function($, _, Parse, PropertyList, PropertyResult, Alert, i18nCommon, i18nProperty) {
    var GMapView, _ref;

    return GMapView = (function(_super) {
      __extends(GMapView, _super);

      function GMapView() {
        this.setMapZoom = __bind(this.setMapZoom, this);
        this.clear = __bind(this.clear, this);
        this.addAll = __bind(this.addAll, this);
        this.addOne = __bind(this.addOne, this);
        this.processResults = __bind(this.processResults, this);
        this.geolocate = __bind(this.geolocate, this);
        this.geocode = __bind(this.geocode, this);
        this.checkForSubmit = __bind(this.checkForSubmit, this);        _ref = GMapView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      GMapView.prototype.el = ".address-form";

      GMapView.prototype.events = {
        'keypress #geolocation-search': 'checkForSubmit',
        'click .search': 'geocode',
        'click .geolocate': 'geolocate'
      };

      GMapView.prototype.initialize = function(attrs) {
        this.mapId = "mapCanvas";
        this.wizard = attrs.wizard;
        this.geocoder = new google.maps.Geocoder();
        this.results = new PropertyList;
        this.browserGeoSupport = navigator.geolocation || google.loader.ClientLocation ? true : false;
        this.listenTo(this.wizard, "wizard:cancel", this.clear);
        this.listenTo(this.wizard, "property:save", this.clear);
        return this.listenTo(this.results, "reset", this.processResults);
      };

      GMapView.prototype.render = function() {
        var p, vars, _i, _len, _ref1;

        vars = {
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        };
        this.$el.html(JST["src/js/templates/property/new/map.jst"](vars));
        this.$searchInput = this.$('#geolocation-search').focus();
        this.$propertyList = this.$('#search-results');
        if (this.browserGeoSupport !== false) {
          this.$('.geolocate').show();
        }
        this.gmap = new google.maps.Map(document.getElementById(this.mapId), {
          zoom: 2,
          center: new google.maps.LatLng(0, 0),
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          mapTypeControl: false,
          streetViewControl: false,
          draggable: false,
          disableDoubleClickZoom: true,
          scrollwheel: false
        });
        if (Parse.User.current().get("property")) {
          new google.maps.Marker({
            position: this.model.GPoint(),
            map: this.map,
            ZIndex: 1,
            icon: {
              url: "/img/icon/pins-sprite.png",
              size: new google.maps.Size(25, 32, "px", "px"),
              origin: new google.maps.Point(50, 0),
              anchor: null,
              scaledSize: null
            }
          });
        } else if (Parse.User.current().get("network")) {
          _ref1 = Parse.User.current().get("network").properties;
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            p = _ref1[_i];
            new google.maps.Marker({
              position: this.model.GPoint(),
              map: this.map,
              ZIndex: 1,
              icon: {
                url: "/img/icon/pins-sprite.png",
                size: new google.maps.Size(25, 32, "px", "px"),
                origin: new google.maps.Point(50, this.model.pos() * 32),
                anchor: null,
                scaledSize: null
              }
            });
          }
        }
        return this;
      };

      GMapView.prototype.checkForSubmit = function(e) {
        if (e.keyCode !== 13) {
          return;
        }
        return this.geocode(e);
      };

      GMapView.prototype.geocode = function(e) {
        var _this = this;

        e.preventDefault();
        return this.geocoder.geocode({
          address: this.$searchInput.val()
        }, function(results, status) {
          var msg, p, _i, _len, _ref1;

          if (status === google.maps.GeocoderStatus.OK) {
            if ($(".wizard-actions .next").is("[disabled]")) {
              $(".wizard-actions .next").removeProp("disabled");
            }
            if (Parse.User.current()) {
              if (Parse.User.current().get("network")) {
                _ref1 = Parse.User.current().get("network").properties.models;
                for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                  p = _ref1[_i];
                  if (results[0].geometry.location.equals(p.GPoint())) {
                    msg = i18nProperty.errors.taken_by_network(p.id);
                    return new Alert({
                      event: 'geocode',
                      fade: false,
                      message: msg,
                      type: 'error'
                    });
                  }
                }
              }
            }
            _this.result = _this.parse(results[0]);
            _this.results.setCenter(new Parse.GeoPoint(results[0].geometry.location.lat(), results[0].geometry.location.lng()));
            return _this.results.fetch();
          } else {
            return alert("Geocoding failed: " + status);
          }
        });
      };

      GMapView.prototype.geolocate = function(e) {
        var _this = this;

        e.preventDefault();
        if (this.browserGeoSupport) {
          if (navigator.geolocation) {
            return navigator.geolocation.getCurrentPosition(function(position) {
              _this.model.set("center", new Parse.GeoPoint(position.coords));
              return _this.geocode({
                latLng: _this.GPoint(_this.model.get("center"))
              });
            });
          } else if (google.loader.ClientLocation) {
            this.model.set("center", new Parse.GeoPoint(google.loader.ClientLocation));
            return this.geocode({
              latLng: this.GPoint(this.model.get("center"))
            });
          }
        } else {
          this.model.set("center", new Parse.GeoPoint());
          alert(i18nProperty.errors.no_geolocaiton);
          return this.geocode({
            latLng: this.GPoint(this.model.get("center"))
          });
        }
      };

      GMapView.prototype.processResults = function() {
        var center;

        this.model.set(this.result);
        this.$searchInput.val(this.model.get('formatted_address'));
        center = this.model.GPoint();
        this.gmap.setCenter(center);
        this.setMapZoom();
        if (this.gmarker) {
          this.gmarker.setPosition(center);
        } else {
          this.gmarker = new google.maps.Marker({
            position: center,
            map: this.gmap
          });
        }
        return this.addAll();
      };

      GMapView.prototype.addOne = function(p) {
        var view;

        view = new PropertyResult({
          model: p,
          map: this.gmap
        });
        return this.$propertyList.append(view.render().el);
      };

      GMapView.prototype.addAll = function() {
        this.$propertyList.html("");
        if (this.results.length !== 0) {
          this.$('li.empty').remove();
          this.results.each(this.addOne);
          return this.wizard.delegateEvents();
        } else {
          return this.$propertyList.html("<li class='empty text-center font-large'>" + i18nProperty.search.no_results + "</li>");
        }
      };

      GMapView.prototype.parse = function(res) {
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
      };

      GMapView.prototype.clear = function() {
        this.undelegateEvents();
        this.remove();
        return delete this;
      };

      GMapView.prototype.setMapZoom = function() {
        switch (this.model.get("location_type")) {
          case "APPROXIMATE":
            return this.gmap.setZoom(10);
          case "GEOMETRIC_CENTER":
            return this.gmap.setZoom(12);
          case "RANGE_INTERPOLATED":
            return this.gmap.setZoom(16);
          case "ROOFTOP":
            return this.gmap.setZoom(16);
          default:
            return this.gmap.setZoom(8);
        }
      };

      return GMapView;

    })(Parse.View);
  });

}).call(this);
