(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Image', 'templates/image/image'], function($, _, Parse, Image) {
    var ImageView;
    return ImageView = (function(_super) {

      __extends(ImageView, _super);

      function ImageView() {
        return ImageView.__super__.constructor.apply(this, arguments);
      }

      ImageView.prototype.tagName = "li";

      ImageView.prototype.template = JST["src/js/templates/image/item.jst"];

      ImageView.prototype.events = {
        "click .toggle": "toggleDone",
        "dblclick label.image-content": "edit",
        "click .image-destroy": "clear",
        "keypress .edit": "updateOnEnter",
        "blur .edit": "close"
      };

      ImageView.prototype.initialize = function() {
        _.bindAll(this, "render", "close", "remove");
        this.model.bind("change", this.render);
        return this.model.bind("destroy", this.remove);
      };

      ImageView.prototype.render = function() {
        $(this.el).html(this.template(this.model.toJSON()));
        this.input = this.$(".edit");
        return this;
      };

      ImageView.prototype.toggleDone = function() {
        return this.model.toggle();
      };

      ImageView.prototype.edit = function() {
        $(this.el).addClass("editing");
        return this.input.focus();
      };

      ImageView.prototype.close = function() {
        this.model.save({
          content: this.input.val()
        });
        return $(this.el).removeClass("editing");
      };

      ImageView.prototype.updateOnEnter = function(e) {
        if (e.keyCode === 13) {
          return this.close();
        }
      };

      ImageView.prototype.clear = function() {
        return this.model.destroy();
      };

      return ImageView;

    })(Parse.View);
  });

}).call(this);
