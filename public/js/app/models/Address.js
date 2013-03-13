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
        return this.trigger("marker:add", this);
      },
      toGPoint: function() {
        return new google.maps.LatLng(this.get("center")._latitude, this.get("center")._longitude);
      }
    });
  });

}).call(this);
