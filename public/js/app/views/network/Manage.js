(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "views/property/Manage", "views/todo/Manage"], function($, _, Parse, ManagePropertiesView, ManageTodosView) {
    var ManageNetworkView;
    return ManageNetworkView = (function(_super) {

      __extends(ManageNetworkView, _super);

      function ManageNetworkView() {
        return ManageNetworkView.__super__.constructor.apply(this, arguments);
      }

      ManageNetworkView.prototype.el = $("#main");

      ManageNetworkView.prototype.initialize = function() {
        return this.render();
      };

      ManageNetworkView.prototype.render = function() {
        if (Parse.User.current()) {
          this.user = Parse.User.current();
          return new ManagePropertiesView();
        } else {
          return new ManageTodosView();
        }
      };

      return ManageNetworkView;

    })(Parse.View);
  });

}).call(this);
