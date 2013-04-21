(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["views/lease/New"], function(NewLeaseView) {
    var EditLeaseView;
    return EditLeaseView = (function(_super) {

      __extends(EditLeaseView, _super);

      function EditLeaseView() {
        return EditLeaseView.__super__.constructor.apply(this, arguments);
      }

      return EditLeaseView;

    })(NewLeaseView);
  });

}).call(this);
