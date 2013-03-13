(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/Image'], function($, _, Parse, Image) {
    var ImageList;
    return ImageList = (function(_super) {

      __extends(ImageList, _super);

      function ImageList() {
        return ImageList.__super__.constructor.apply(this, arguments);
      }

      ImageList.prototype.model = Image;

      ImageList.prototype.done = function() {
        return this.filter(function(Image) {
          return Image.get("done");
        });
      };

      ImageList.prototype.remaining = function() {
        return this.without.apply(this, this.done());
      };

      ImageList.prototype.nextOrder = function() {
        if (!this.length) {
          return 1;
        }
        return this.last().get("order") + 1;
      };

      ImageList.prototype.comparator = function(Image) {
        return Image.get("order");
      };

      return ImageList;

    })(Parse.Collection);
  });

}).call(this);
