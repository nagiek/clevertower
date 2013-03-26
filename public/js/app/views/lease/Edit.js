(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["models/Lease", "views/lease/New", "templates/lease/new"], function(Lease, NewLeaseView) {
    var EditLeaseView;
    return EditLeaseView = (function(_super) {

      __extends(EditLeaseView, _super);

      function EditLeaseView() {
        return EditLeaseView.__super__.constructor.apply(this, arguments);
      }

      EditLeaseView.prototype.initialize = function(attrs) {
        var _this = this;
        return new Parse.Query("Lease").include("unit").get(attrs.subId, {
          success: function(model) {
            return new NewLeaseView({
              model: model,
              property: attrs.property
            });
          }
        });
      };

      return EditLeaseView;

    })(Parse.View);
  });

}).call(this);
