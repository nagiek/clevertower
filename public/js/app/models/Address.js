(function() {

  define(['underscore', 'backbone', "gmaps"], function(_, Parse) {
    var Address;
    return Address = Parse.Object.extend("Address", {
      defaults: {
        center: new Parse.GeoPoint,
        formatted_address: '',
        address_components: [],
        location_type: "APPROXIMATE",
        thoroughfare: '',
        locality: '',
        neighbourhood: '',
        administrative_area_level_1: '',
        administrative_area_level_2: '',
        country: '',
        postal_code: ''
      },
      initialize: function(attrs) {
        this.$adrsLat = $('#address_lat', '.address-form');
        this.$adrsLng = $('#address_lng', '.address-form');
        this.$resultComponents = $('#address_components', '.address-form');
        this.$location_type = $('#address_location_type', '.address-form');
        this.$adrsThr = $('#address_thoroughfare', '.address-form');
        this.$adrsLty = $('#address_locality', '.address-form');
        this.$adrsNhd = $('#address_neighbourhood', '.address-form');
        this.$adrsAd1 = $('#address_administrative_area_level_1', '.address-form');
        this.$adrsAd2 = $('#address_administrative_area_level_2', '.address-form');
        this.$adrsCty = $('#address_country', '.address-form');
        this.$adrsPCd = $('#address_postal_code', '.address-form');
        return this.trigger("marker:add", this);
      },
      toGPoint: function() {
        return new google.maps.LatLng(this.get("center")._latitude, this.get("center")._longitude);
      }
    });
  });

}).call(this);
