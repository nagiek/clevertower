(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "collections/UnitList", "models/Property", "models/Unit", "models/Lease", "views/lease/New"], function($, _, Parse, UnitList, Property, Unit, Lease, NewLeaseView, i18nCommon, i18nLease) {
    var AddLeaseToPropertyView, _ref;

    return AddLeaseToPropertyView = (function(_super) {
      __extends(AddLeaseToPropertyView, _super);

      function AddLeaseToPropertyView() {
        _ref = AddLeaseToPropertyView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      AddLeaseToPropertyView.prototype.el = ".content";

      AddLeaseToPropertyView.prototype.initialize = function(attrs) {
        var vars;

        this.on("view:change", this.clear);
        this.baseUrl = attrs.baseUrl;
        vars = {
          property: this.model,
          network: this.model.get("network")
        };
        if (attrs.params && attrs.params.unit) {
          this.model.prep('units');
          if (this.model.units.length === 0) {
            this.model.units.fetch();
          }
          vars.unit = {
            __type: "Pointer",
            className: "Unit",
            objectId: attrs.params.unit
          };
        }
        return this.lease = new Lease(vars);
      };

      AddLeaseToPropertyView.prototype.render = function() {
        this.form = new NewLeaseView({
          model: this.lease,
          property: this.model,
          baseUrl: this.baseUrl
        }).render();
        return this;
      };

      AddLeaseToPropertyView.prototype.clear = function() {
        this.form.stopListening();
        this.form.undelegateEvents();
        delete this.form;
        this.stopListening();
        this.undelegateEvents();
        delete this;
        return Parse.history.navigate(this.baseUrl);
      };

      return AddLeaseToPropertyView;

    })(Parse.View);
  });

}).call(this);
