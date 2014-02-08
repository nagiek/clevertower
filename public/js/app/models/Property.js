(function() {
  define(['underscore', 'backbone', "collections/UnitList", "collections/LeaseList", "collections/InquiryList", "collections/TenantList", "collections/ApplicantList", "collections/ListingList", "collections/PhotoList", "collections/ActivityList", "collections/CommentList", "models/Unit", "models/Lease", "i18n!nls/common"], function(_, Parse, UnitList, LeaseList, InquiryList, TenantList, ApplicantList, ListingList, PhotoList, ActivityList, CommentList, Unit, Lease, i18nCommon) {
    var Property;

    Property = Parse.Object.extend("Property", {
      className: "Property",
      defaults: {
        center: new Parse.GeoPoint,
        offset: {
          lat: 50,
          lng: 50
        },
        formatted_address: '',
        address_components: [],
        location_type: "APPROXIMATE",
        thoroughfare: '',
        locality: '',
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
        var center, lat, lng, offset;

        center = this.get("center");
        if (!center) {
          return new google.maps.LatLng(0, 0);
        }
        offset = this.get("offset" || {
          lat: 50,
          lng: 50
        });
        lat = center._latitude + (offset.lat - 50) * 250 * 7.871 / 100000000;
        lng = center._longitude + (offset.lng - 50) * 250 * 7.871 / 100000000;
        return new google.maps.LatLng(lat, lng);
      },
      url: function() {
        return "/properties/" + this.id;
      },
      publicUrl: function() {
        return "/places/" + (this.country()) + "/" + (this.get("administrative_area_level_1")) + "/" + (this.get("locality")) + "/" + this.id + "/" + (this.slug());
      },
      slug: function() {
        return this.get("profile").slug();
      },
      country: function() {
        return i18nCommon.countries[this.get("country")];
      },
      city: function() {
        if (this.get("location")) {
          return this.get("location").url();
        } else {
          this.get("locality").replace(/\s+/g, '-') + "--";
          +this.get("administrative_area_level_1").replace(/\s+/g, '-') + "--";
          return +i18nCommon.countries[this.get("country")].replace(/\s+/g, '-');
        }
      },
      scrub: function(attrs) {
        var attr, bools, _i, _len;

        bools = ['electricity', 'furniture', 'gas', 'heat', 'hot_water', 'air_conditioning', 'back_yard', 'balcony', 'cats_allowed', 'concierge', 'dogs_allowed', 'doorman', 'elevator', 'exposed_brick', 'fireplace', 'front_yard', 'gym', 'laundry', 'indoor_parking', 'outdoor_parking', 'pool', 'sauna', 'wheelchair', 'approx', 'public', 'anon'];
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
        basedOnNetwork = user && network && this.get("network") && this.get("network").id === network.id;
        this[collectionName] = (function() {
          switch (collectionName) {
            case "leases":
              return new LeaseList([], {
                property: this
              });
            case "photos":
              return new PhotoList([], {
                property: this
              });
            case "activity":
              if (basedOnNetwork) {
                return network.activity;
              } else {
                return new ActivityList([], {
                  property: this
                });
              }
              break;
            case "comments":
              if (basedOnNetwork) {
                return network.comments;
              } else {
                return new CommentList([], {
                  property: this
                });
              }
              break;
            case "units":
              if (basedOnNetwork) {
                return network.units;
              } else {
                return new UnitList([], {
                  property: this
                });
              }
              break;
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
    Property.url = function(id) {
      return "/properties/" + id;
    };
    Property.publicUrl = function(country, area, locality, id, slug) {
      return "/places/" + country + "/" + area + "/" + locality + "/" + id + "/" + slug;
    };
    Property.slug = function(title) {
      return title.replace(/\s+/g, '-').toLowerCase();
    };
    Property.country = function(country) {
      return i18nCommon.countries[country];
    };
    return Property;
  });

}).call(this);
