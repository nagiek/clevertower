(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/Unit'], function($, _, Parse, Unit) {
    var UnitList;
    return UnitList = (function(_super) {
      var comparator;

      __extends(UnitList, _super);

      function UnitList() {
        return UnitList.__super__.constructor.apply(this, arguments);
      }

      UnitList.prototype.model = Unit;

      UnitList.prototype.initialize = function(attrs) {
        return this.property = attrs.property;
      };

      UnitList.prototype.url = function() {
        return "/properties/" + (this.property.get("id")) + "/units";
      };

      comparator = function(unit) {
        var char, title;
        title = unit.get("title");
        char = title.charAt(title.length - 1);
        if (isNaN(char)) {
          return Number(title.substr(0, title.length - 1)) + char.charCodeAt() / 128;
        } else {
          return Number(title);
        }
      };

      return UnitList;

    })(Parse.Collection);
  });

}).call(this);
