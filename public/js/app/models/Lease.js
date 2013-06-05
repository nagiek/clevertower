(function() {
  define(['underscore', 'backbone', "collections/TenantList", "models/Property", "models/Unit", "moment", "i18n!nls/common"], function(_, Parse, TenantList, Property, Unit, moment, i18nCommon) {
    var Lease;

    return Lease = Parse.Object.extend("Lease", {
      className: "Lease",
      defaults: {
        rent: 0,
        keys: 0,
        garage_remotes: 0,
        parking_fee: 0,
        security_deposit: 0,
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
      scrub: function(lease) {
        var attr, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;

        _ref = ['rent', 'keys', 'garage_remotes', 'security_deposit', 'parking_fee'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          attr = _ref[_i];
          if (lease[attr] === '' || lease[attr] === '0') {
            lease[attr] = 0;
          }
          if (lease[attr]) {
            lease[attr] = Number(lease[attr]);
          }
        }
        _ref1 = ['start_date', 'end_date'];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          attr = _ref1[_j];
          if (lease[attr] !== '') {
            lease[attr] = moment(lease[attr], i18nCommon.dates.moment_format).toDate();
          }
          if (typeof lease[attr] === 'string') {
            lease[attr] = new Date;
          }
        }
        _ref2 = ['checks_received', 'first_month_paid', 'last_month_paid'];
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          attr = _ref2[_k];
          lease[attr] = lease[attr] !== "" ? true : false;
        }
        return lease;
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
      },
      prep: function(collectionName, options) {
        var network, user;

        if (this[collectionName]) {
          return this[collectionName];
        }
        switch (collectionName) {
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
