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

      PhotoList.prototype.done = function() {
        return this.filter(function(Photo) {
          return Photo.get("done");
        });
      };

      PhotoList.prototype.remaining = function() {
        return this.without.apply(this, this.done());
      };

      PhotoList.prototype.nextOrder = function() {
        if (!this.length) {
          return 1;
        }
        return this.last().get("order") + 1;
      };

      PhotoList.prototype.comparator = function(Photo) {
        return Photo.get("order");
      };

      return PhotoList;

    })(Parse.Collection);
  });

}).call(this);
