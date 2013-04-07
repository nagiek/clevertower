(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Map', "i18n!nls/common", "i18n!nls/property", "templates/property/new/map", "gmaps"], function($, _, Parse, Map, i18nCommon, i18nProperty) {
    var GMapView;
    return GMapView = (function(_super) {

      __extends(GMapView, _super);

      function GMapView() {
        this.setMapZoom = __bind(this.setMapZoom, this);
        return GMapView.__super__.constructor.apply(this, arguments);
      }

      GMapView.prototype.el = ".address-form";

      GMapView.prototype.events = {
        'keypress #geolocation-search': 'checkForSubmit',
        'click .search': 'geocode',
        'click .geolocate': 'geolocate'
      };

      GMapView.prototype.initialize = function(attrs) {
        var _this = this;
        _.bindAll(this, 'checkForSubmit', 'geocode', 'geolocate');
        this.mapId = "mapCanvas";
        this.wizard = attrs.wizard;
        this.marker = attrs.marker;
        this.model = new Map({
          divId: this.mapId,
          marker: this.marker
        });
        this.browserGeoSupport = navigator.geolocation || google.loader.ClientLocation ? true : false;
        this.wizard.on("wizard:cancel", function() {
          _this.undelegateEvents();
          _this.remove();
          return delete _this;
        });
        this.wizard.on("property:save", function() {
          _this.undelegateEvents();
          _this.remove();
          return delete _this;
        });
        this.marker.on("change", function(updatedPoint) {
          var center;
          _this.$searchInput.val(updatedPoint.get('formatted_address'));
          center = _this.model.GPoint(updatedPoint.get("center"));
          _this.gmap.setCenter(center);
          _this.setMapZoom(updatedPoint);
          if (_this.gmarker) {
            return _this.gmarker.setPosition(center);
          } else {
            return _this.gmarker = new google.maps.Marker({
              position: center,
              map: _this.gmap
            });
          }
        });
        return this.model.on("marker:remove", function(removedPoint) {
          this.gmarker.setMap(null);
          return delete this.marker;
        });
      };

      GMapView.prototype.render = function() {
        this.$el.html(JST["src/js/templates/property/new/map.jst"]({
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        }));
        this.$searchInput = this.$('#geolocation-search').focus();
        if (this.browserGeoSupport !== false) {
          this.$('.geolocate').show();
        }
        this.gmap = new google.maps.Map(document.getElementById(this.mapId), this.model.get("opts"));
        return this;
      };

      GMapView.prototype.checkForSubmit = function(e) {
        if (e.keyCode !== 13) {
          return;
        }
        return this.geocode(e);
      };

      GMapView.prototype.geocode = function(e) {
        e.preventDefault();
        return this.model.geocode({
          address: this.$searchInput.val()
        });
      };

      GMapView.prototype.geolocate = function(e) {
        e.preventDefault();
        if (this.browserGeoSupport) {
          return this.model.geolocate();
        } else {
          return alert(i18nProperty.errors.messages.no_geolocation);
        }
      };

      GMapView.prototype.setMapZoom = function(marker) {
        switch (marker.get("location_type")) {
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
