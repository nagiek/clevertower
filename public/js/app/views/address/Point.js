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
        this.model.$location_type.val(this.model.get('location_type'));
        this.model.$adrsLat.val(this.model.get('lat'));
        this.model.$adrsLng.val(this.model.get('lng'));
        this.model.$adrsThr.val(this.model.get('thoroughfare'));
        this.model.$adrsLty.val(this.model.get('locality'));
        this.model.$adrsNhd.val(this.model.get('neighbourhood'));
        this.model.$adrsAd1.val(this.model.get('administrative_area_level_1'));
        this.model.$adrsAd2.val(this.model.get('administrative_area_level_2'));
        this.model.$adrsCty.val(this.model.get('country'));
        this.model.$adrsPCd.val(this.model.get('postal_code'));
        return this;
      };

      GPointView.prototype.remove = function() {
        this.gMarker.setMap(null);
        this.gMarker = null;
        this.model.$formatted_address.val('');
        this.model.$location_type.val('');
        this.model.$adrsLat.val('');
        this.model.$adrsLng.val('');
        this.model.$adrsThr.val('');
        this.model.$adrsLty.val('');
        this.model.$adrsAdm.val('');
        this.model.$adrsCty.val('');
        this.model.$adrsPCd.val('');
        return GPointView.__super__.remove.apply(this, arguments);
      };

      return GPointView;

    })(Parse.View);
  });

}).call(this);
