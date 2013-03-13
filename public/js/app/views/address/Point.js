(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/address", "gmaps", 'templates/address/map'], function($, _, Parse, Address) {
    var GPointView;
    return GPointView = (function(_super) {

      __extends(GPointView, _super);

      function GPointView() {
        return GPointView.__super__.constructor.apply(this, arguments);
      }

      GPointView.prototype.initialize = function(attrs) {
        var _this = this;
        this.gmap = attrs.gmap;
        this.$searchInput = attrs.$searchInput;
        this.el = "#" + this.model.divId;
        this.gMarker = new google.maps.Marker({
          position: this.model.toGPoint(),
          map: this.gmap
        });
        this.model.on("change", function(updatedPoint) {
          _this.gMarker.setPosition(updatedPoint.toGPoint());
          return _this.render();
        });
        this.model.on("remove", function() {
          _this.remove();
          return delete _this;
        });
        return this.render();
      };

      GPointView.prototype.setMapZoom = function(location_type) {
        switch (location_type) {
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

      GPointView.prototype.render = function() {
        this.setMapZoom(this.model.get('location_type'));
        this.$searchInput.val(this.model.get('formatted_address'));
        return this;
      };

      GPointView.prototype.remove = function() {
        this.gMarker.setMap(null);
        this.gMarker = null;
        return GPointView.__super__.remove.apply(this, arguments);
      };

      return GPointView;

    })(Parse.View);
  });

}).call(this);
