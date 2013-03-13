(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/Unit'], function($, _, Parse, Unit) {
    var UnitList;
    return UnitList = (function(_super) {

      __extends(UnitList, _super);

      function UnitList() {
        return UnitList.__super__.constructor.apply(this, arguments);
      }

      UnitList.prototype.model = Unit;

      UnitList.prototype.url = function() {
        return "/properties/" + (property.get("id")) + "/units";
      };

      UnitList.prototype.done = function() {
        return this.filter(function(Unit) {
          return Unit.get("done");
        });
      };

      UnitList.prototype.remaining = function() {
        return this.without.apply(this, this.done());
      };

      UnitList.prototype.nextOrder = function() {
        if (!this.length) {
          return 1;
        }
        return this.last().get("order") + 1;
      };

      UnitList.prototype.comparator = function(Unit) {
        return Unit.get("order");
      };

      return UnitList;

    })(Parse.Collection);
  });

}).call(this);
