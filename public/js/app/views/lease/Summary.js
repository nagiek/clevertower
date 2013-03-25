(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", 'models/Unit', 'models/Lease', 'views/helper/Alert', "i18n!nls/lease", "i18n!nls/unit", "i18n!nls/common", 'templates/lease/summary'], function($, _, Parse, moment, Unit, Lease, Alert, i18nLease, i18nUnit, i18nCommon) {
    var LeaseSummaryView;
    return LeaseSummaryView = (function(_super) {

      __extends(LeaseSummaryView, _super);

      function LeaseSummaryView() {
        return LeaseSummaryView.__super__.constructor.apply(this, arguments);
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
        this.title = attrs.title;
        this.onUnit = attrs.onUnit ? true : false;
        this.link_text = this.onUnit ? i18nCommon.nouns.link : i18nCommon.classes.lease;
        this.model.on("save:success", function() {
          return _this.render();
        });
        this.model.on("remove", function() {
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
          title: this.title,
          moment: moment,
          propertyId: this.model.get("property").id,
          objectId: this.model.get("objectId"),
          isNew: this.model.isNew(),
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease
        });
        $(this.el).html(JST["src/js/templates/lease/summary.jst"](vars));
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
          this.model.destroy();
          this.remove();
          this.undelegateEvents();
          delete this;
          return Parse.history.navigate("/properties/" + id);
        }
      };

      return LeaseSummaryView;

    })(Parse.View);
  });

}).call(this);
