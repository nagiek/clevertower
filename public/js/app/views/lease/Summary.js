(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", 'models/Unit', 'models/Lease', 'views/helper/Alert', "i18n!nls/lease", "i18n!nls/unit", "i18n!nls/common", 'templates/lease/summary'], function($, _, Parse, moment, Unit, Lease, Alert, i18nLease, i18nUnit, i18nCommon) {
    var LeaseSummaryView, _ref;

    return LeaseSummaryView = (function(_super) {
      __extends(LeaseSummaryView, _super);

      function LeaseSummaryView() {
        this.clear = __bind(this.clear, this);        _ref = LeaseSummaryView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      LeaseSummaryView.prototype.tagName = "tr";

      LeaseSummaryView.prototype.events = {
        'blur input': 'update',
        'blur textarea': 'update',
        'blur select': 'updateS',
        'click .remove': 'remove',
        'click .delete': 'kill'
      };

      LeaseSummaryView.prototype.initialize = function(attrs) {
        var _this = this;

        this.onUnit = attrs.onUnit ? true : false;
        this.baseUrl = attrs.baseUrl;
        this.link_text = this.onUnit ? i18nCommon.nouns.link : i18nCommon.classes.lease;
        this.listenTo(this.model, "save:success", this.render);
        this.listenTo(this.model, "destroy", this.clear);
        return this.listenTo(this.model, "invalid", function(unit, error) {
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

      LeaseSummaryView.prototype.render = function() {
        var modelVars, vars;

        modelVars = this.model.toJSON();
        modelVars.start_date = moment(this.model.get("start_date")).format("LL");
        modelVars.end_date = moment(this.model.get("end_date")).format("LL");
        vars = _.merge(modelVars, {
          link_text: this.link_text,
          onUnit: this.onUnit,
          propertyId: this.model.get("property").id,
          unitId: this.model.get("unit").id,
          unitTitle: this.model.get("unit").get("title"),
          moment: moment,
          baseUrl: this.baseUrl,
          objectId: this.model.get("objectId"),
          isNew: this.model.isNew(),
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease
        });
        this.$el.html(JST["src/js/templates/lease/summary.jst"](vars));
        return this;
      };

      LeaseSummaryView.prototype.update = function(e) {
        var name, value;

        name = e.currentTarget.name;
        value = e.currentTarget.value;
        this.model.set(name, value);
        return e;
      };

      LeaseSummaryView.prototype.updateS = function(e) {
        var name, value;

        name = e.currentTarget.name;
        value = Number(e.currentTarget.value);
        this.model.set(name, value);
        return e;
      };

      LeaseSummaryView.prototype.kill = function(e) {
        var id;

        e.preventDefault();
        if (confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)) {
          id = this.model.get("property").id;
          return this.model.destroy();
        }
      };

      LeaseSummaryView.prototype.clear = function() {
        this.remove();
        this.undelegateEvents();
        return delete this;
      };

      return LeaseSummaryView;

    })(Parse.View);
  });

}).call(this);
