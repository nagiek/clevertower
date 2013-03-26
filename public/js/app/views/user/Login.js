(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "i18n!nls/devise", "i18n!nls/user", 'templates/user/login'], function($, _, Parse, i18nDevise, i18nUser) {
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
        var _this = this;
        e.preventDefault();
        this.$(".login-form button").attr("disabled", "disabled");
        return Parse.User.logIn(this.$("#login-username").val(), {
          password: this.$("#login-password").val()
        }, {
          success: function(user) {
            new UserView;
            Parse.history.navigate("/");
            _this.undelegateEvents();
            _this.remove();
            return delete _this;
          },
          error: function(user, error) {
            var msg;
            _this.$('.username-group').addClass('error');
            _this.$('.password-group').addClass('error');
            msg = (function() {
              switch (error.code) {
                case -1:
                  return i18nDevise.errors.fields_missing;
                default:
                  return i18nDevise.errors.invalid_login;
              }
            })();
            _this.$(".login-form .alert-error").html(msg).show();
            return _this.$(".login-form button").removeAttr("disabled");
          }
        });
      };

      LoginView.prototype.render = function() {
        this.$el.html(JST["src/js/templates/user/login.jst"]({
          i18nDevise: i18nDevise,
          i18nUser: i18nUser
        }));
        this.delegateEvents();
        return this;
      };

      return LoginView;

    })(Parse.View);
  });

}).call(this);
