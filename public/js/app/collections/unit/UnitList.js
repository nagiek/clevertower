(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/Unit', 'models/Lease'], function($, _, Parse, Unit, Lease) {
    var UnitList;
    return UnitList = (function(_super) {

      __extends(UnitList, _super);

      function UnitList() {
        this.prepopulate = __bind(this.prepopulate, this);
        return UnitList.__super__.constructor.apply(this, arguments);
      }

      UnitList.prototype.model = Unit;

      UnitList.prototype.initialize = function(models, attrs) {
        this.property = attrs.property;
        return this.query = new Parse.Query(Unit).equalTo("property", this.property).include("activeLease");
      };

      UnitList.prototype.url = function() {
        return "/properties/" + (this.property.get("id")) + "/units";
      };

      UnitList.prototype.comparator = function(unit) {
        var char, title;
        title = unit.get("title");
        char = title.charAt(title.length - 1);
        if (isNaN(char)) {
          return Number(title.substr(0, title.length - 1)) + char.charCodeAt() / 128;
        } else {
          return Number(title);
        }
      };

      UnitList.prototype.prepopulate = function() {
        var char, newChar, newTitle, title, unit;
        if (this.length === 0) {
          unit = new Unit({
            property: this.property
          });
        } else {
          unit = this.at(this.length - 1).clone();
          unit.set("has_lease", false);
          unit.unset("activeLease");
          title = unit.get('title');
          newTitle = title.substr(0, title.length - 1);
          char = title.charAt(title.length - 1);
          newChar = isNaN(char) ? String.fromCharCode(char.charCodeAt() + 1) : String(Number(char) + 1);
          unit.set('title', newTitle + newChar);
        }
        return this.add(unit);
      };

      return UnitList;

    })(Parse.Collection);
  });

}).call(this);
