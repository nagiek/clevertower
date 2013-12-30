(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "templates/helper/alert"], function($, _, Parse) {
    var AlertView, _ref;

    return AlertView = (function(_super) {
      __extends(AlertView, _super);

      function AlertView() {
        _ref = AlertView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      AlertView.prototype.tagName = 'div';

      AlertView.prototype.className = 'alert';

      AlertView.prototype.events = {
        'click .close': 'clear'
      };

      AlertView.prototype.initialize = function(attrs) {
        this.container = $('#messages');
        this.fade = attrs.fade ? attrs.fade : false;
        this.vars = attrs;
        if (!attrs.type) {
          this.vars.type = 'success';
        }
        if (!attrs.dismiss) {
          this.vars.dismiss = true;
        }
        if (!attrs.heading) {
          this.vars.heading = '';
        }
        if (!attrs.message) {
          this.vars.message = '';
        }
        if (!attrs.buttons) {
          this.vars.buttons = '';
        }
        if (!attrs.event) {
          this.vars.event = '';
        }
        return this.render();
      };

      AlertView.prototype.render = function() {
        var alert;

        if (!this.vars.event) {
          return;
        }
        alert = this.container.find("#alert-" + this.event);
        if (alert.length === 0) {
          alert = this.container.append(JST['src/js/templates/helper/alert.jst'](this.vars));
          return alert.delay(3000).fadeOut();
        } else {
          alert.removeClass("alert-");
          alert.addClass("alert-" + this.vars.type);
          return alert.find(".message").html(this.vars.message);
        }
      };

      AlertView.prototype.clear = function() {
        var _this = this;

        this.$el.removeClass("in");
        return setTimeout(function() {
          _this.remove();
          _this.undelegateEvents();
          return delete _this;
        }, 150);
      };

      AlertView.prototype.setError = function(msg) {
        this.vars.message = msg;
        this.vars.type = 'danger';
        return this.render();
      };

      return AlertView;

    })(Parse.View);
  });

}).call(this);
