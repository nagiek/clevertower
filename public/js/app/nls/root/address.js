(function() {

  define({
    actions: {
      search: "Search",
      geolocate: "Geolocate Me"
    },
    errors: {
      messages: {
        invalid_address: "You must add an address.",
        insufficient_data: "We were unable to determine your address.",
        no_geolocaiton: "Your browser doesn't support geolocation.",
        network_property: "Your group already has a property at this address.",
        user_property: "You already have a property at this address."
      }
    }
  });

}).call(this);
