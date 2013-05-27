(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Photo', "i18n!nls/common", 'templates/photo/show'], function($, _, Parse, Photo, i18nCommon) {
    var PhotoView, _ref;

    return PhotoView = (function(_super) {
      __extends(PhotoView, _super);

      function PhotoView() {
        _ref = PhotoView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PhotoView.prototype.tagName = "li";

      PhotoView.prototype.className = "span4";

      PhotoView.prototype.events = {
        "click .photo-destroy": "kill"
      };

      PhotoView.prototype.initialize = function() {
        var _this = this;

        _.bindAll(this, "render", "close", "remove");
        this.model.on("change", this.render);
        return this.model.on("destroy", function() {
          _this.remove();
          _this.undelegateEvents();
          return delete _this;
        });
      };

      PhotoView.prototype.render = function() {
        $(this.el).html(JST["src/js/templates/photo/show.jst"](_.merge(this.model.toJSON(), {
          i18nCommon: i18nCommon
        })));
        return this;
      };

      PhotoView.prototype.kill = function() {
        if (confirm(i18nCommon.actions.confirm)) {
          return this.model.destroy();
        }
      };

      return PhotoView;

    })(Parse.View);
  });

}).call(this);
