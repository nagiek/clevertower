(function() {

  define(['underscore', 'backbone'], function(_, Parse) {
    var Property;
    return Property = Parse.Object.extend("Property", {
      defaults: {
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
        imgs: [],
        tasks: [],
        incomes: [],
        expenses: [],
        vacant_units: [],
        units: [],
        air_conditioning: 0,
        back_yard: 0,
        balcony: 0,
        cats_allowed: 0,
        concierge: 0,
        dogs_allowed: 0,
        doorman: 0,
        elevator: 0,
        exposed_brick: 0,
        fireplace: 0,
        front_yard: 0,
        gym: 0,
        laundry: 0,
        indoor_parking: 0,
        outdoor_parking: 0,
        pool: 0,
        sauna: 0,
        wheelchair: 0,
        electricity: 0,
        furniture: 0,
        gas: 0,
        heat: 0,
        hot_water: 0,
        init: 1,
        "public": 1
      },
      cover: function(format) {
        var img;
        img = this.get("image_" + format);
        if (img == null) {
          img = "/img/fallback/property-" + format + ".png";
        }
        return img;
      }
    });
  });

}).call(this);
