(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["views/lease/New", "templates/lease/edit"], function(NewLeaseView) {
    var EditLeaseView, _ref;

    return EditLeaseView = (function(_super) {
      __extends(EditLeaseView, _super);

      function EditLeaseView() {
        _ref = EditLeaseView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      return EditLeaseView;

    })(NewLeaseView);
  });

}).call(this);
