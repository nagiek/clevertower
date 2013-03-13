(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Unit', "i18n!nls/Unit", "i18n!nls/common", 'templates/unit/mass-form'], function($, _, Parse, Unit, i18nUnit, i18nCommon) {
    var UnitMassFormView;
    return UnitMassFormView = (function(_super) {

      __extends(UnitMassFormView, _super);

      function UnitMassFormView() {
        return UnitMassFormView.__super__.constructor.apply(this, arguments);
      }

      UnitMassFormView.prototype.tagName = "tr";

      UnitMassFormView.prototype.initialize = function() {
        return this.model.bind("change", this.render);
      };

      UnitMassFormView.prototype.render = function() {
        $(this.el).html(JST["src/js/templates/unit/mass-form.jst"](_.merge(this.model.toJSON(), {
          i18nUnit: i18nUnit,
          i18nCommon: i18nCommon
        })));
        this.input = this.$(".edit");
        return this;
      };

      return UnitMassFormView;

    })(Parse.View);
  });

}).call(this);
