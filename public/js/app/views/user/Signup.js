(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'templates/user/signup'], function($, _, Parse) {
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
        var password, username,
          _this = this;
        username = this.$("#signup-username").val();
        password = this.$("#signup-password").val();
        Parse.User.signUp(username, password, {
          ACL: new Parse.ACL()
        }, {
          success: function(user) {
            var AppView;
            AppView = require("views/app/Main");
            new AppView();
            _this.undelegateEvents();
            _this.remove();
            return delete _this;
          },
          error: function(user, error) {
            self.$(".signup-form .error").html(error.message).show();
            return this.$(".signup-form button").removeAttr("disabled");
          }
        });
        this.$(".signup-form button").attr("disabled", "disabled");
        return e.preventDefault();
      };

      SignupView.prototype.render = function() {
        this.$el.html(JST["src/js/templates/user/signup.jst"]);
        this.delegateEvents();
        return this;
      };

      return SignupView;

    })(Parse.View);
  });

}).call(this);
