(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Image', "i18n!nls/common", 'templates/image/show'], function($, _, Parse, Image, i18nCommon) {
    var ImageView;
    return ImageView = (function(_super) {

      __extends(ImageView, _super);

      function ImageView() {
        return ImageView.__super__.constructor.apply(this, arguments);
      }

      ImageView.prototype.tagName = "li";

      ImageView.prototype.className = "span3";

      ImageView.prototype.events = {
        "click .image-destroy": "kill"
      };

      ImageView.prototype.initialize = function() {
        _.bindAll(this, "render", "close", "remove");
        this.model.bind("change", this.render);
        return this.model.bind("destroy", this.remove);
      };

      ImageView.prototype.render = function() {
        $(this.el).html(JST["src/js/templates/image/show.jst"](_.merge(this.model.toJSON(), {
          i18nCommon: i18nCommon
        })));
        return this;
      };

      ImageView.prototype.kill = function() {
        if (confirm(i18nCommon.actions.confirm)) {
          return this.model.destroy();
        }
      };

      return ImageView;

    })(Parse.View);
  });

}).call(this);
