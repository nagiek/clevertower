(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "collections/unit/UnitList", "models/Property", "models/Unit", "models/Lease", "views/lease/New"], function($, _, Parse, UnitList, Property, Unit, Lease, NewLeaseView, i18nCommon, i18nLease) {
    var AddLeaseToPropertyView;
    return AddLeaseToPropertyView = (function(_super) {

      __extends(AddLeaseToPropertyView, _super);

      function AddLeaseToPropertyView() {
        return AddLeaseToPropertyView.__super__.constructor.apply(this, arguments);
      }

      AddLeaseToPropertyView.prototype.el = "#content";

      AddLeaseToPropertyView.prototype.initialize = function(attrs) {
        var vars;
        vars = {
          property: this.model
        };
        if (attrs.params.unit) {
          this.model.loadUnits();
          vars.unit = {
            __type: "Pointer",
            className: "Unit",
            objectId: attrs.params.unit
          };
        }
        this.lease = new Lease(vars);
        return this.render();
      };

      AddLeaseToPropertyView.prototype.render = function() {
        var form;
        return form = new NewLeaseView({
          model: this.lease,
          property: this.model
        });
      };

      AddLeaseToPropertyView.prototype._return = function() {
        this.remove();
        this.undelegateEvents();
        delete this;
        return Parse.history.navigate("/properties/" + this.model.id);
      };

      return AddLeaseToPropertyView;

    })(Parse.View);
  });

}).call(this);
