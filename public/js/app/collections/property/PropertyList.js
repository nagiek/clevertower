(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/Property'], function($, _, Parse, Property) {
    var PropertyList;
    return PropertyList = (function(_super) {

      __extends(PropertyList, _super);

      function PropertyList() {
        return PropertyList.__super__.constructor.apply(this, arguments);
      }

      PropertyList.prototype.model = Property;

      PropertyList.prototype.url = function() {
        return "/properties";
      };

      PropertyList.prototype.done = function() {
        return this.filter(function(Property) {
          return Property.get("done");
        });
      };

      PropertyList.prototype.remaining = function() {
        return this.without.apply(this, this.done());
      };

      PropertyList.prototype.nextOrder = function() {
        if (!this.length) {
          return 1;
        }
        return this.last().get("order") + 1;
      };

      PropertyList.prototype.comparator = function(Property) {
        return Property.get("order");
      };

      return PropertyList;

    })(Parse.Collection);
  });

}).call(this);
