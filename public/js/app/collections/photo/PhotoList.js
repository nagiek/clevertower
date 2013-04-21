(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/Photo'], function($, _, Parse, Photo) {
    var PhotoList;
    return PhotoList = (function(_super) {

      __extends(PhotoList, _super);

      function PhotoList() {
        return PhotoList.__super__.constructor.apply(this, arguments);
      }

      PhotoList.prototype.model = Photo;

      PhotoList.prototype.query = new Parse.Query("Photo");

      PhotoList.prototype.initialize = function(models, attrs) {
        if (attrs.property) {
          return this.query.equalTo("property", attrs.property);
        }
      };

      return PhotoList;

    })(Parse.Collection);
  });

}).call(this);
