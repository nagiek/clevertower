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

      PropertyList.prototype.query = new Parse.Query("Property").equalTo("user", Parse.User.current());

      return PropertyList;

    })(Parse.Collection);
  });

}).call(this);
