(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'models/Property', "views/property/Show", "i18n!nls/property", "i18n!nls/common", 'templates/property/summary'], function($, _, Parse, Property, ShowPropertyView, i18nProperty, i18nCommon) {
    var PropertySummaryView;
    return PropertySummaryView = (function(_super) {

      __extends(PropertySummaryView, _super);

      function PropertySummaryView() {
        this.show = __bind(this.show, this);
        return PropertySummaryView.__super__.constructor.apply(this, arguments);
      }

      PropertySummaryView.prototype.tagName = "li";

      PropertySummaryView.prototype.className = "row";

      PropertySummaryView.prototype.events = {
        'click h2 a': 'show',
        'click dl dt a': 'show',
        'click .btn-toolbar .dropdown-menu a': 'show'
      };

      PropertySummaryView.prototype.initialize = function() {
        var _this = this;
        this.model.collection.on('show', function() {
          return _this.undelegateEvents();
        });
        this.model.collection.on('close', function() {
          return _this.delegateEvents();
        });
        return this.model.on("change", this.render);
      };

      PropertySummaryView.prototype.show = function(e) {
        $('#main').append(new ShowPropertyView({
          model: this.model,
          e: e
        }).render().el);
        return this.model.collection.trigger('show');
      };

      PropertySummaryView.prototype.render = function() {
        var details, vars;
        details = {
          cover: this.model.cover('profile'),
          tasks: '0',
          incomes: '0',
          expenses: '0',
          vacant_units: '0'
        };
        vars = _.merge(this.model.toJSON(), details, {
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
