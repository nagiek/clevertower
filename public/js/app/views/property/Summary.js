(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Property', "i18n!nls/property", "i18n!nls/common", 'templates/property/summary'], function($, _, Parse, Property, i18nProperty, i18nCommon) {
    var PropertySummaryView;
    return PropertySummaryView = (function(_super) {

      __extends(PropertySummaryView, _super);

      function PropertySummaryView() {
        return PropertySummaryView.__super__.constructor.apply(this, arguments);
      }

      PropertySummaryView.prototype.tagName = "li";

      PropertySummaryView.prototype.className = "row";

      PropertySummaryView.prototype.initialize = function() {
        this.model.set({
          cover: this.model.cover('profile')
        });
        this.model.set({
          tasks: '0',
          incomes: '0',
          expenses: '0',
          vacant_units: '0'
        });
        return this.model.bind("change", this.render);
      };

      PropertySummaryView.prototype.render = function() {
        var vars;
        vars = _.merge(this.model.toJSON(), {
          unitsLength: this.model.unitsLength ? this.model.unitsLength : 0,
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        });
        $(this.el).html(JST["src/js/templates/property/summary.jst"](vars));
        this.input = this.$(".edit");
        return this;
      };

      return PropertySummaryView;

    })(Parse.View);
  });

}).call(this);
