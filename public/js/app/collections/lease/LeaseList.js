(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/Lease'], function($, _, Parse, Lease) {
    var LeaseList;
    return LeaseList = (function(_super) {
      var comparator;

      __extends(LeaseList, _super);

      function LeaseList() {
        return LeaseList.__super__.constructor.apply(this, arguments);
      }

      LeaseList.prototype.model = Lease;

      LeaseList.prototype.initialize = function(attrs) {
        this.query = new Parse.Query(Lease);
        if (attrs.property) {
          this.property = attrs.property;
          return this.query.equalTo("property", this.property);
        } else if (attrs.unit) {
          this.unit = attrs.unit;
          return this.query.equalTo("unit", this.unit);
        }
      };

      LeaseList.prototype.url = function() {
        return "/properties/" + (this.property.get("id")) + "/leases";
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

      return LeaseList;

    })(Parse.Collection);
  });

}).call(this);
