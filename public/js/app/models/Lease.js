(function() {

  define(['underscore', 'backbone', "models/Property", "models/Unit", "moment"], function(_, Parse, Property, Unit, moment) {
    var Lease;
    return Lease = Parse.Object.extend("Lease", {
      className: "Lease",
      defaults: {
        rent: 0,
        keys: 0,
        garage_remotes: 0,
        parking_fee: 0,
        parking_space: "",
        first_month_paid: false,
        last_month_paid: false,
        checks_received: false
      },
      initialize: function() {
        return _.bindAll(this, 'isActive');
      },
      isActive: function() {
        var ed, sd, today;
        sd = this.get("start_date");
        ed = this.get("end_date");
        if (!(sd && ed)) {
          return false;
        }
        today = new Date;
        return sd < today && today < ed;
      },
      validate: function(attrs, options) {
        var error;
        if (attrs == null) {
          attrs = {};
        }
        if (options == null) {
          options = {};
        }
        if (attrs.start_date && attrs.end_date) {
          if (attrs.start_date === '' || attrs.end_date === '') {
            return {
              message: 'dates_missing'
            };
          }
          if (moment(attrs.start_date).isAfter(attrs.end_date)) {
            return {
              message: 'dates_incorrect'
            };
          }
        }
        if (attrs.unit) {
          if (attrs.unit.id === '') {
            return {
              message: 'unit_missing'
            };
          } else if (attrs.unit.isNew() && attrs.unit.isValid()) {
            if (error = attrs.unit.validationError) {
              return error;
            }
          }
        }
        return false;
      }
    });
  });

}).call(this);
