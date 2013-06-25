(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'collections/LeaseList', 'models/Property', 'models/Lease', 'views/helper/Alert', 'views/lease/Summary', "i18n!nls/common", "i18n!nls/property", "i18n!nls/unit", "i18n!nls/lease", 'templates/property/sub/leases'], function($, _, Parse, LeaseList, Property, Lease, Alert, LeaseView, i18nCommon, i18nProperty, i18nUnit, i18nLease) {
    var PropertyLeasesView, _ref;

    return PropertyLeasesView = (function(_super) {
      __extends(PropertyLeasesView, _super);

      function PropertyLeasesView() {
        this.addOne = __bind(this.addOne, this);
        this.addAll = __bind(this.addAll, this);
        this.clear = __bind(this.clear, this);
        this.render = __bind(this.render, this);        _ref = PropertyLeasesView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PropertyLeasesView.prototype.el = ".content";

      PropertyLeasesView.prototype.initialize = function(attrs) {
        this.baseUrl = attrs.baseUrl;
        this.editing = false;
        this.on("view:change", this.clear);
        this.listenTo(this.model.leases, "add", this.addOne);
        return this.listenTo(this.model.leases, "reset", this.addAll);
      };

      PropertyLeasesView.prototype.render = function() {
        var vars;

        vars = _.merge({
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease
        });
        this.$el.html(JST["src/js/templates/property/sub/leases.jst"](vars));
        this.$table = this.$("#leases-table");
        this.$list = this.$("#leases-table tbody");
        this.$actions = this.$(".form-actions");
        this.$undo = this.$actions.find('.undo');
        if (this.model.leases.length === 0) {
          this.model.leases.fetch();
        } else {
          this.addAll();
        }
        return this;
      };

      PropertyLeasesView.prototype.clear = function(e) {
        this.undelegateEvents();
        return delete this;
      };

      PropertyLeasesView.prototype.addAll = function(collection, filter) {
        this.$list.html('');
        if (this.model.leases.length > 0) {
          return this.model.leases.each(this.addOne);
        } else {
          return this.$list.html('<p class="empty">' + i18nLease.empty.collection + '</p>');
        }
      };

      PropertyLeasesView.prototype.addOne = function(lease) {
        var view;

        this.$('p.empty').remove();
        view = new LeaseView({
          model: lease,
          baseUrl: this.baseUrl
        });
        this.$list.append(view.render().el);
        if (this.editing) {
          return view.$el.find('.view-specific').toggleClass('hide');
        }
      };

      return PropertyLeasesView;

    })(Parse.View);
  });

}).call(this);
