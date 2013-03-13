(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "views/network/Manage"], function($, _, Parse, UserView, ManageNetworkView) {
    var AppView;
    return AppView = (function(_super) {

      __extends(AppView, _super);

      function AppView() {
        return AppView.__super__.constructor.apply(this, arguments);
      }

      AppView.prototype.el = $("#main");

      AppView.prototype.initialize = function() {
        return this.render();
      };

      AppView.prototype.render = function() {
        return new ManageNetworkView();
      };

      return AppView;

    })(Parse.View);
  });

}).call(this);
