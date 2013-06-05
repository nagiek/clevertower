(function() {
  define(['underscore', 'backbone', "collections/UnitList", "collections/LeaseList", "collections/InquiryList", "collections/TenantList", "collections/ApplicantList", "collections/ListingList", "collections/PhotoList", "models/Unit", "models/Lease", "underscore.inflection"], function(_, Parse, UnitList, LeaseList, InquiryList, TenantList, ApplicantList, ListingList, PhotoList, Unit, Lease, Listing, inflection) {
    var Property;

    return Property = Parse.Object.extend("Property", {
      className: "Property",
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
      pos: function() {
        if (this.collection) {
          return this.collection.indexOf(this);
        } else {
          return 0;
        }
      },
      GPoint: function() {
        return new google.maps.LatLng(this.get("center")._latitude, this.get("center")._longitude);
      },
      url: function() {
        return "/" + this.collection.url + "/" + this.id;
      },
      publicUrl: function() {
        return "/places/" + (this.country()) + "/" + (this.get("administrative_area_level_1")) + "/" + (this.get("locality")) + "/" + this.id + "/" + (this.slug());
      },
      slug: function() {
        return this.get("title").replace(/\s+/g, '-').toLowerCase();
      },
      country: function() {
        return Parse.App.countryCodes[this.get("country")];
      },
      cover: function(format) {
        var img;

        img = this.get("image_" + format);
        if (img === '' || (img == null)) {
          img = "/img/fallback/property-" + format + ".png";
        }
        return img;
      },
      scrub: function(attrs) {
        var attr, bools, _i, _len;

        bools = ['electricity', 'furniture', 'gas', 'heat', 'hot_water', 'air_conditioning', 'back_yard', 'balcony', 'cats_allowed', 'concierge', 'dogs_allowed', 'doorman', 'elevator', 'exposed_brick', 'fireplace', 'front_yard', 'gym', 'laundry', 'indoor_parking', 'outdoor_parking', 'pool', 'sauna', 'wheelchair', 'public', 'anon'];
        for (_i = 0, _len = bools.length; _i < _len; _i++) {
          attr = bools[_i];
          attrs[attr] = attrs[attr] === "on" || attrs[attr] === "1" ? true : false;
        }
        return attrs;
      },
      prep: function(collectionName, options) {
        var basedOnNetwork, network, user;

        if (this[collectionName]) {
          return this[collectionName];
        }
        user = Parse.User.current();
        if (user) {
          network = user.get("network");
        }
        basedOnNetwork = user && network && this.get("network").id === network.id;
        this[collectionName] = (function() {
          switch (collectionName) {
            case "units":
              return new UnitList([], {
                property: this
              });
            case "leases":
              return new LeaseList([], {
                property: this
              });
            case "photos":
              return new PhotoList([], {
                property: this
              });
            case "inquiries":
              if (basedOnNetwork) {
                return network.inquiries;
              } else {
                return new InquiryList([], {
                  property: this
                });
              }
              break;
            case "listings":
              if (basedOnNetwork) {
                return network.listings;
              } else {
                return new ListingList([], {
                  property: this
                });
              }
              break;
            case "tenants":
              if (basedOnNetwork) {
                return network.tenants;
              } else {
                return new TenantList([], {
                  property: this
                });
              }
              break;
            case "applicants":
              if (basedOnNetwork) {
                return network.applicants;
              } else {
                return new ApplicantList([], {
                  property: this
                });
              }
          }
        }).call(this);
        return this[collectionName];
      }
    });
  });

}).call(this);
