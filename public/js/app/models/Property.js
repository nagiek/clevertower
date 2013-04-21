(function() {

  define(['underscore', 'backbone', "collections/unit/UnitList", "collections/lease/LeaseList", "models/Unit", "models/Lease", "underscore.inflection"], function(_, Parse, UnitList, LeaseList, Unit, Lease, inflection) {
    var Property;
    return Property = Parse.Object.extend("Property", {
      className: "Property",
      initialize: function() {
        return _.bindAll(this, "cover", "prep");
      },
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
        postal_code: '',
        image_thumb: "",
        image_profile: "",
        image_full: "",
        description: "",
        phone: "",
        email: "",
        website: "",
        title: "",
        property_type: "",
        year: "",
        mls: "",
        air_conditioning: false,
        back_yard: false,
        balcony: false,
        cats_allowed: false,
        concierge: false,
        dogs_allowed: false,
        doorman: false,
        elevator: false,
        exposed_brick: false,
        fireplace: false,
        front_yard: false,
        gym: false,
        laundry: false,
        indoor_parking: false,
        outdoor_parking: false,
        pool: false,
        sauna: false,
        wheelchair: false,
        electricity: false,
        furniture: false,
        gas: false,
        heat: false,
        hot_water: false,
        init: false,
        "public": false
      },
      url: function() {
        return "/" + this.collection.url + "/" + this.id;
      },
      cover: function(format) {
        var img;
        img = this.get("image_" + format);
        if (img === '' || !(img != null)) {
          img = "/img/fallback/property-" + format + ".png";
        }
        return img;
      },
      prep: function(collectionName, options) {
        var network, user;
        if (this[collectionName]) {
          return this[collectionName];
        }
        switch (collectionName) {
          case "units":
            this[collectionName] = new UnitList([], {
              property: this
            });
            break;
          case "leases":
            this[collectionName] = new LeaseList([], {
              property: this
            });
            break;
          case "tenants":
            user = Parse.User.current();
            if (user) {
              network = user.get("network");
            }
            if (!(user && network)) {
              this[collectionName] = new TenantList([], {
                lease: this
              });
            } else {
              this[collectionName] = network.tenants ? network.tenants : new TenantList([], {
                lease: this
              });
            }
        }
        return this[collectionName];
      }
    });
  });

}).call(this);
