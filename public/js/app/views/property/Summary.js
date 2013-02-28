(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Property', 'templates/property/summary'], function($, _, Parse, Property) {
    var PropertySummaryView;
    return PropertySummaryView = (function(_super) {

      __extends(PropertySummaryView, _super);

      function PropertySummaryView() {
        return PropertySummaryView.__super__.constructor.apply(this, arguments);
      }

      PropertySummaryView.prototype.tagName = "li";

      PropertySummaryView.prototype.events = {
        "click .toggle": "toggleDone",
        "dblclick label.property-content": "edit",
        "keypress .edit": "updateOnEnter",
        "blur .edit": "close"
      };

      PropertySummaryView.prototype.initialize = function() {
        _.bindAll(this, "render", "close");
        return this.model.bind("change", this.render);
      };

      PropertySummaryView.prototype.render = function() {
        $(this.el).html(JST["src/js/templates/property/summary.jst"](this.model.toJSON()));
        this.input = this.$(".edit");
        return this;
      };

      PropertySummaryView.prototype.toggleDone = function() {
        return this.model.toggle();
      };

      PropertySummaryView.prototype.edit = function() {
        $(this.el).addClass("editing");
        return this.input.focus();
      };

      PropertySummaryView.prototype.close = function() {
        this.model.save({
          content: this.input.val()
        });
        return $(this.el).removeClass("editing");
      };

      PropertySummaryView.prototype.updateOnEnter = function(e) {
        if (e.keyCode === 13) {
          return this.close();
        }
      };

      return PropertySummaryView;

    })(Parse.View);
  });

}).call(this);
