(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Unit', "i18n!nls/Unit", "i18n!nls/common", 'templates/unit/new', 'templates/unit/edit', 'templates/unit/status'], function($, _, Parse, Unit, i18nUnit, i18nCommon) {
    var UnitEditView, _ref;

    return UnitEditView = (function(_super) {
      __extends(UnitEditView, _super);

      function UnitEditView() {
        this.render = __bind(this.render, this);        _ref = UnitEditView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      UnitEditView.prototype.tagName = "tr";

      UnitEditView.prototype.events = {
        'blur input': 'update',
        'blur textarea': 'update',
        'blur select': 'update',
        'click .remove': 'remove',
        'click .delete': 'kill'
      };

      UnitEditView.prototype.initialize = function() {};

      UnitEditView.prototype.render = function() {
        var template;

        template = this.model.isNew() ? "src/js/templates/unit/new.jst" : "src/js/templates/unit/edit.jst";
        $(this.el).html(JST[template](_.merge(this.model.toJSON(), {
          propertyId: this.model.get("property").id,
          i18nUnit: i18nUnit,
          i18nCommon: i18nCommon
        })));
        return this;
      };

      UnitEditView.prototype.update = function(e) {
        var name, value;

        name = e.currentTarget.name;
        value = e.currentTarget.value;
        this.model.set(name, value);
        return e;
      };

      UnitEditView.prototype.kill = function(e) {
        var id;

        e.preventDefault();
        if (confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)) {
          id = this.model.get("property").id;
          this.model.destroy();
          this.remove();
          this.undelegateEvents();
          delete this;
          return Parse.history.navigate("/properties/" + id);
        }
      };

      return UnitEditView;

    })(Parse.View);
  });

}).call(this);
