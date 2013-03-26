(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "i18n!nls/devise", 'templates/user/signup'], function($, _, Parse, i18nDevise) {
    var SignupView;
    return SignupView = (function(_super) {

      __extends(SignupView, _super);

      function SignupView() {
        return SignupView.__super__.constructor.apply(this, arguments);
      }

      SignupView.prototype.events = {
        "submit form.signup-form": "signUp"
      };

      SignupView.prototype.el = "#signup";

      SignupView.prototype.initialize = function() {
        _.bindAll(this, "signUp");
        this.$parent = $('#registration-menu');
        this.$parent.append(this.el);
        this.render();
        return this.$parent.show();
      };

      SignupView.prototype.signUp = function(e) {
        var user,
          _this = this;
        e.preventDefault();
        this.$(".signup-form button").attr("disabled", "disabled");
        user = new Parse.User({
          username: this.$("#signup-username").val(),
          password: this.$("#signup-password").val()
        });
        return user.signUp(null, {
          success: function(user) {
            new UserView;
            Parse.history.navigate("/");
            _this.undelegateEvents();
            _this.remove();
            return delete _this;
          },
          error: function(user, error) {
            var msg;
            _this.$(".signup-form .error").removeClass('error');
            msg = (function() {
              switch (error.code) {
                case 202:
                  return i18nDevise.errors.username_taken;
                case -1:
                  return i18nDevise.errors.fields_missing;
                default:
                  return error.message;
              }
            })();
            switch (error.code) {
              case 202:
                _this.$('.username-group').addClass('error');
                break;
              case -1:
                _this.$('.username-group').addClass('error');
                _this.$('.password-group').addClass('error');
            }
            _this.$(".signup-form .alert-error").html(msg).show();
            return _this.$(".signup-form button").removeAttr("disabled");
          }
        });
      };

      SignupView.prototype.render = function() {
        this.$el.html(JST["src/js/templates/user/signup.jst"]({
          i18nDevise: i18nDevise
        }));
        this.delegateEvents();
        return this;
      };

      return SignupView;

    })(Parse.View);
  });

}).call(this);
