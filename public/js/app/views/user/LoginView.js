(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'templates/user/login'], function($, _, Parse, LoginTemplate) {
    var LoginView;
    return LoginView = (function(_super) {

      __extends(LoginView, _super);

      function LoginView() {
        return LoginView.__super__.constructor.apply(this, arguments);
      }

      LoginView.prototype.events = {
        "submit form.login-form": "logIn",
        "submit form.signup-form": "signUp"
      };

      LoginView.prototype.el = ".content";

      LoginView.prototype.initialize = function() {
        _.bindAll(this, "logIn", "signUp");
        return this.render();
      };

      LoginView.prototype.logIn = function(e) {
        var password, username,
          _this = this;
        username = this.$("#login-username").val();
        password = this.$("#login-password").val();
        Parse.User.logIn(username, password, {
          success: function(user) {
            var ManageTodosView;
            ManageTodosView = require("views/todo/ManageTodosView");
            new ManageTodosView();
            _this.undelegateEvents();
            return delete _this;
          },
          error: function(user, error) {
            _this.$(".login-form .error").html("Invalid username or password. Please try again.").show();
            return _this.$(".login-form button").removeAttr("disabled");
          }
        });
        this.$(".login-form button").attr("disabled", "disabled");
        return false;
      };

      LoginView.prototype.signUp = function(e) {
        var password, username,
          _this = this;
        username = this.$("#signup-username").val();
        password = this.$("#signup-password").val();
        Parse.User.signUp(username, password, {
          ACL: new Parse.ACL()
        }, {
          success: function(user) {
            new ManageTodosView;
            _this.undelegateEvents();
            return delete _this;
          },
          error: function(user, error) {
            self.$(".signup-form .error").html(error.message).show();
            return this.$(".signup-form button").removeAttr("disabled");
          }
        });
        this.$(".signup-form button").attr("disabled", "disabled");
        return false;
      };

      LoginView.prototype.render = function() {
        this.$el.html(JST["src/js/templates/user/login.jst"]);
        return this.delegateEvents();
      };

      return LoginView;

    })(Parse.View);
  });

}).call(this);
