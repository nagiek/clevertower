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
        'click .close': 'delete'
      };

      AlertView.prototype.initialize = function(attrs) {
        this.container = $('#messages');
        this.fade = attrs.fade != null ? attrs.fade : false;
        this.event = attrs.event != null ? attrs.event : '';
        this.vars = attrs;
        if (attrs.type == null) {
          this.vars.type = 'success';
        }
        if (attrs.dismiss == null) {
          this.vars.dismiss = true;
        }
        if (attrs.heading == null) {
          this.vars.heading = '';
        }
        if (attrs.message == null) {
          this.vars.message = '';
        }
        if (attrs.buttons == null) {
          this.vars.buttons = '';
        }
        this.vars.event = this.event;
        return this.render();
      };

      AlertView.prototype.render = function() {
        var alert;

        if (this.event !== '' && this.container.find("#alert-" + this.event).length === 0) {
          alert = this.container.append(JST['src/js/templates/helper/alert.jst'](this.vars));
          if (this.fade) {
            return alert.delay(3000).fadeOut();
          }
        }
      };

      AlertView.prototype["delete"] = function() {
        return delete this;
      };

      return AlertView;

    })(Parse.View);
  });

}).call(this);
