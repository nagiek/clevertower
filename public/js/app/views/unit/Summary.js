(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", 'models/Unit', 'models/Lease', 'views/helper/Alert', "i18n!nls/lease", "i18n!nls/unit", "i18n!nls/common", 'templates/unit/summary'], function($, _, Parse, moment, Unit, Lease, Alert, i18nLease, i18nUnit, i18nCommon) {
    var UnitSummaryView, _ref;

    return UnitSummaryView = (function(_super) {
      __extends(UnitSummaryView, _super);

      function UnitSummaryView() {
        this.newOnEnter = __bind(this.newOnEnter, this);        _ref = UnitSummaryView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      UnitSummaryView.prototype.tagName = "tr";

      UnitSummaryView.prototype.events = {
        'blur input': 'update',
        'blur textarea': 'update',
        'blur select': 'updateS',
        'click .remove': 'clear',
        'click .delete': 'delete',
        "keypress .title": "newOnEnter"
      };

      UnitSummaryView.prototype.initialize = function() {
        var _this = this;

        this.model.on("change:title", function() {
          return _this.$('.unit-link').html(_this.model.get("title"));
        });
        this.model.on("save:success", function() {
          return _this.render();
        });
        this.model.on("destroy", function() {
          _this.remove();
          _this.undelegateEvents();
          return delete _this;
        });
        return this.model.on("invalid", function(unit, error) {
          var msg;

          _this.$el.addClass('error');
          switch (error.message) {
            case 'title_missing':
              _this.$('.title-group .control-group').addClass('error');
          }
          msg = (typeof error.code === "function" ? error.code(i18nCommon.errors[error.message]) : void 0) ? void 0 : i18nUnit.errors[error.message];
          return new Alert({
            event: 'unit-invalid',
            fade: false,
            message: msg,
            type: 'error'
          });
        });
      };

      UnitSummaryView.prototype.render = function() {
        var end_date, vars;

        vars = _.merge(this.model.toJSON(), {
          moment: moment,
          objectId: this.model.id ? this.model.id : false,
          propertyId: this.model.get("property").id,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease,
          isNew: this.model.isNew()
        });
        if (vars.activeLease = this.model.get("activeLease")) {
          end_date = this.model.get("activeLease").get("end_date");
          vars.end_date = this.model.get("has_lease") && end_date ? moment(end_date).format("MMM DD YYYY") : false;
        } else {
          vars.activeLease = false;
        }
        $(this.el).html(JST["src/js/templates/unit/summary.jst"](vars));
        return this;
      };

      UnitSummaryView.prototype.update = function(e) {
        var name, value;

        name = e.currentTarget.name;
        value = e.currentTarget.value;
        this.model.set(name, value);
        return e;
      };

      UnitSummaryView.prototype.updateS = function(e) {
        var name, value;

        name = e.currentTarget.name;
        value = Number(e.currentTarget.value);
        this.model.set(name, value);
        return e;
      };

      UnitSummaryView.prototype.clear = function(e) {
        e.preventDefault();
        return this.model.destroy();
      };

      UnitSummaryView.prototype["delete"] = function(e) {
        var id;

        e.preventDefault();
        if (confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)) {
          id = this.model.get("property").id;
          this.model.destroy();
          return Parse.history.navigate("/properties/" + id);
        }
      };

      UnitSummaryView.prototype.newOnEnter = function(e) {
        if (e.keyCode !== 13) {
          return;
        }
        this.update(e);
        return this.model.collection.prepopulate();
      };

      return UnitSummaryView;

    })(Parse.View);
  });

}).call(this);
