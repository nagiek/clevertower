(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "moment", "collections/LeaseList", 'models/Unit', 'models/Lease', "views/lease/summary", "i18n!nls/unit", "i18n!nls/lease", "i18n!nls/listing", "i18n!nls/common", 'templates/unit/show'], function($, _, Parse, moment, LeaseList, Unit, Lease, LeaseView, i18nUnit, i18nLease, i18nListing, i18nCommon) {
    var ShowUnitView, _ref;

    return ShowUnitView = (function(_super) {
      __extends(ShowUnitView, _super);

      function ShowUnitView() {
        this.addOne = __bind(this.addOne, this);
        this.addAll = __bind(this.addAll, this);        _ref = ShowUnitView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ShowUnitView.prototype.el = ".content";

      ShowUnitView.prototype.initialize = function(attrs) {
        this.property = attrs.property;
        this.baseUrl = attrs.baseUrl;
        this.model.prep("leases");
        this.listenTo(this.model.leases, "reset", this.addAll);
        return this.listenTo(this.model.leases, "add", this.addOne);
      };

      ShowUnitView.prototype.render = function() {
        var modelVars, vars;

        modelVars = this.model.toJSON();
        vars = _.merge(modelVars, {
          i18nUnit: i18nUnit,
          i18nLease: i18nLease,
          i18nListing: i18nListing,
          i18nCommon: i18nCommon,
          baseUrl: this.baseUrl
        });
        this.$el.html(JST["src/js/templates/unit/show.jst"](vars));
        this.$('[rel=tooltip]').tooltip();
        this.$list = this.$('#leases-table tbody');
        this.model.leases.fetch();
        return this;
      };

      ShowUnitView.prototype.addAll = function(collection, filter) {
        var _this = this;

        this.$list.html('');
        return this.model.leases.chain().select(function(l) {
          return l.get("unit").id === _this.model.id;
        }).each(this.addOne);
      };

      ShowUnitView.prototype.addOne = function(lease) {
        var view;

        this.$('p.empty').hide();
        if (lease.get("unit").id === this.model.id) {
          view = new LeaseView({
            model: lease,
            onUnit: true
          });
          return this.$list.append(view.render().el);
        }
      };

      return ShowUnitView;

    })(Parse.View);
  });

}).call(this);
