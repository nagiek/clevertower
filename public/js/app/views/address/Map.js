(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Map', "views/address/Point", "i18n!nls/address", "templates/address/map", "gmaps"], function($, _, Parse, Map, GPointView, i18nAddress) {
    var GMapView;
    return GMapView = (function(_super) {

      __extends(GMapView, _super);

      function GMapView() {
        return GMapView.__super__.constructor.apply(this, arguments);
      }

      GMapView.prototype.el = ".address-form";

      GMapView.prototype.events = {
        'keypress #geolocation-search': 'checkForSubmit',
        'click .search': 'geocode',
        'click .geolocate': 'geolocate'
      };

      GMapView.prototype.initialize = function(attrs) {
        var divId,
          _this = this;
        _.bindAll(this, 'checkForSubmit', 'geocode', 'geolocate');
        divId = "mapCanvas";
        this.address = attrs.address;
        this.wizard = attrs.wizard;
        this.model = new Map({
          divId: divId,
          marker: this.address
        });
        this.$searchInput = this.$el.find('#geolocation-search').focus();
        this.browserGeoSupport = navigator.geolocation || google.loader.ClientLocation ? true : false;
        if (this.browserGeoSupport !== false) {
          this.$el.find('.geolocate').show();
        }
        this.gmap = new google.maps.Map(document.getElementById(divId), this.model.get("opts"));
        this.wizard.on("wizard:cancel", function() {
          _this.undelegateEvents();
          _this.remove();
          delete _this.gmap;
          delete _this.marker;
          delete _this.model;
          return delete _this;
        });
        this.wizard.on("property:save", function() {
          _this.undelegateEvents();
          _this.remove();
          delete _this.gmap;
          delete _this.marker;
          delete _this.model;
          return delete _this;
        });
        this.model.marker.on("change", function(updatedPoint) {
          return _this.gmap.setCenter(updatedPoint.toGPoint());
        });
        this.model.on("marker:add", function(newPoint) {
          return _this.marker = new GPointView({
            model: newPoint,
            gmap: _this.gmap,
            $searchInput: _this.$searchInput
          });
        });
        return this.model.on("marker:remove", function(removedPoint) {
          this.model.marker.remove();
          return delete this.marker;
        });
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
          return alert(i18nAddress.errors.messages.no_geolocation);
        }
      };

      GMapView.prototype.render = function() {
        return this;
      };

      return GMapView;

    })(Parse.View);
  });

}).call(this);
