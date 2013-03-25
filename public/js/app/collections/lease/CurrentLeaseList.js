(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/Lease'], function($, _, Parse, Lease) {
    var CurrentLeaseList;
    return CurrentLeaseList = (function(_super) {
      var comparator;

      __extends(CurrentLeaseList, _super);

      function CurrentLeaseList() {
        return CurrentLeaseList.__super__.constructor.apply(this, arguments);
      }

      CurrentLeaseList.prototype.model = Lease;

      CurrentLeaseList.prototype.initialize = function(attrs) {
        var today;
        this.property = attrs.property;
        today = new Date;
        this.query = new Parse.Query(Lease);
        this.query.equalTo("property", this.property);
        this.query.lessThan("start_date", today);
        return this.query.greaterThan("end_date", today);
      };

      comparator = function(lease) {
        var char, title;
        title = lease.get("unit").get("title");
        char = title.charAt(title.length - 1);
        if (isNaN(char)) {
          return Number(title.substr(0, title.length - 1)) + char.charCodeAt() / 128;
        } else {
          return Number(title);
        }
      };

      return CurrentLeaseList;

    })(Parse.Collection);
  });

}).call(this);
