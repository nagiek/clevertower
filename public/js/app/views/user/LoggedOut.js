(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'views/helper/Alert', "i18n!nls/common", "i18n!nls/devise", "i18n!nls/user", 'templates/user/logged_out_menu', 'templates/user/reset_password'], function($, _, Parse, Alert, i18nCommon, i18nDevise, i18nUser) {
    var LoggedOutView;
    return LoggedOutView = (function(_super) {

      __extends(LoggedOutView, _super);

      function LoggedOutView() {
        return LoggedOutView.__super__.constructor.apply(this, arguments);
      }

      LoggedOutView.prototype.el = "#user-menu";

      LoggedOutView.prototype.events = {
        "submit form.login-form": "logIn",
        "submit form.signup-form": "signUp",
        "click .reset-password-modal": "showResetPasswordModal"
      };

      LoggedOutView.prototype.initialize = function() {
        _.bindAll(this, "logIn", "signUp", "resetPassword", "showResetPasswordModal");
        return $('form#reset-password-form').on("submit", this.resetPassword);
      };

      LoggedOutView.prototype.render = function() {
        var _this = this;
        require(["views/todo/Manage"], function(ManageTodosView) {
          return new ManageTodosView;
        });
        this.$el.html(JST["src/js/templates/user/logged_out_menu.jst"]({
          i18nDevise: i18nDevise,
          i18nUser: i18nUser
        }));
        $('body').append(JST["src/js/templates/user/reset_password.jst"]({
          i18nCommon: i18nCommon,
          i18nDevise: i18nDevise
        }));
        return this;
      };

      LoggedOutView.prototype.showResetPasswordModal = function(e) {
        $('#reset-password-modal').modal();
        return e.preventDefault();
      };

      LoggedOutView.prototype.resetPassword = function(e) {
        e.preventDefault();
        return Parse.User.requestPasswordReset($("#reset-email").val(), {
          success: function() {
            new Alert({
              event: 'reset-password',
              message: i18nDevise.messages.password_reset
            });
            $('#reset-password-modal').find('.error').removeClass('error');
            return $('#reset-password-modal').modal('close');
          },
          error: function(error) {
            var msg;
            msg = (function() {
              switch (error.code) {
                case 125:
                  return i18nDevise.errors.invalid_email_format;
                case 205:
                  return i18nDevise.errors.username_doesnt_exist;
                default:
                  return error.message;
              }
            })();
            $("#reset-email-group").addClass('error');
            return new Alert({
              event: 'reset-password',
              fade: false,
              message: msg,
              type: 'error'
            });
          }
        });
      };

      LoggedOutView.prototype.logIn = function(e) {
        var email, password,
          _this = this;
        e.preventDefault();
        this.$(".login-form button").attr("disabled", "disabled");
        email = this.$("#login-username").val();
        password = this.$("#login-password").val();
        return Parse.User.logIn(email, password, {
          success: function(user) {
            _this.trigger("user:change");
            $('#reset-password-modal').remove();
            Parse.history.navigate("/");
            _this.undelegateEvents();
            return delete _this;
          },
          error: function(user, error) {
            var msg;
            _this.$('.login-form .username-group').addClass('error');
            _this.$('.login-form .password-group').addClass('error');
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

      LoggedOutView.prototype.signUp = function(e) {
        var email, password,
          _this = this;
        e.preventDefault();
        this.$(".signup-form button").attr("disabled", "disabled");
        email = this.$("#signup-username").val();
        password = this.$("#signup-password").val();
        return Parse.User.signUp(email, password, {
          email: email,
          ACL: new Parse.ACL()
        }, {
          success: function(user) {
            _this.trigger("user:change");
            $('#reset-password-modal').remove();
            Parse.history.navigate("/");
            _this.undelegateEvents();
            return delete _this;
          },
          error: function(user, error) {
            var msg;
            _this.$(".signup-form .error").removeClass('error');
            msg = (function() {
              switch (error.code) {
                case 125:
                  return i18nDevise.errors.invalid_email_format;
                case 202:
                  return i18nDevise.errors.username_taken;
                case -1:
                  return i18nDevise.errors.fields_missing;
                default:
                  return error.message;
              }
            })();
            switch (error.code) {
              case 125 || 202:
                _this.$('.username-group').addClass('error');
                break;
              case -1:
                _this.$('.signup-form username-group').addClass('error');
                _this.$('.signup-form password-group').addClass('error');
            }
            _this.$(".signup-form .alert-error").html(msg).show();
            return _this.$(".signup-form button").removeAttr("disabled");
          }
        });
      };

      return LoggedOutView;

    })(Parse.View);
  });

}).call(this);
