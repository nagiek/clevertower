(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'templates/user/login'], function($, _, Parse) {
    var LoginView;
    return LoginView = (function(_super) {

      __extends(LoginView, _super);

      function LoginView() {
        return LoginView.__super__.constructor.apply(this, arguments);
      }

      LoginView.prototype.events = {
        "submit form.login-form": "logIn"
      };

      LoginView.prototype.el = "#login";

      LoginView.prototype.initialize = function() {
        _.bindAll(this, "logIn");
        return this.render();
      };

      LoginView.prototype.logIn = function(e) {
        var password, username,
          _this = this;
        username = this.$("#login-username").val();
        password = this.$("#login-password").val();
        Parse.User.logIn(username, password, {
          success: function(user) {
            var AppView;
            AppView = require("views/app/Main");
            new AppView();
            _this.undelegateEvents();
            _this.remove();
            return delete _this;
          },
          error: function(user, error) {
            _this.$(".login-form .error").html("Invalid email or password. Please try again.").show();
            return _this.$(".login-form button").removeAttr("disabled");
          }
        });
        this.$(".login-form button").attr("disabled", "disabled");
        return e.preventDefault();
      };

      LoginView.prototype.render = function() {
        this.$el.html(JST["src/js/templates/user/login.jst"]);
        this.delegateEvents();
        return this;
      };

      return LoginView;

    })(Parse.View);
  });

}).call(this);
