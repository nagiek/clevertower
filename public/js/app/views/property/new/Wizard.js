(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/Property", "views/helper/Alert", "views/property/new/Map", "i18n!nls/property", "i18n!nls/common", "templates/property/new/map", "templates/property/new/wizard"], function($, _, Parse, Property, Alert, GMapView, i18nProperty, i18nCommon) {
    var PropertyWizardView, _ref;

    return PropertyWizardView = (function(_super) {
      __extends(PropertyWizardView, _super);

      function PropertyWizardView() {
        this.clear = __bind(this.clear, this);
        this.back = __bind(this.back, this);
        this.next = __bind(this.next, this);        _ref = PropertyWizardView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PropertyWizardView.prototype.className = 'wizard';

      PropertyWizardView.prototype.state = 'address';

      PropertyWizardView.prototype.events = {
        'click .back': 'back',
        'click .next': 'next'
      };

      PropertyWizardView.prototype.initialize = function() {
        var _this = this;

        this.model = new Property;
        this.listenTo(this.model, "invalid", function(error) {
          var args, fn, msg;

          console.log(error);
          _this.state = 'address';
          msg = error.message.indexOf(":") > 0 ? (args = error.message.split(":"), fn = args.pop(), i18nProperty.errors[fn](args[0])) : i18nProperty.errors[error.message];
          switch (error.message) {
            case 'title_missing':
              _this.$('#property-title-group').addClass('error');
              break;
            default:
              _this.$('#address-search-group').addClass('error');
          }
          return new Alert({
            event: 'model-save',
            fade: false,
            message: msg,
            type: 'error'
          });
        });
        this.on("address:validated", function() {
          _this.state = 'property';
          _this.model.set('title', _this.model.get('thoroughfare'));
          return require(["views/property/new/New", "templates/property/form"], function(NewPropertyView) {
            _this.form = new NewPropertyView({
              wizard: _this,
              model: _this.model
            });
            _this.map.$el.after(_this.form.render().el);
            _this.map.$el.animate({
              left: "-150%"
            }, 500);
            _this.form.$el.animate({
              left: "0"
            }, 500);
            _this.$('.back').prop({
              disabled: false
            });
            return _this.$('.next').html(i18nCommon.actions.save);
          });
        });
        return this.on("property:save", this.clear);
      };

      PropertyWizardView.prototype.render = function() {
        var vars;

        vars = {
          i18nCommon: i18nCommon,
          setup: !Parse.User.current() || (!Parse.User.current().get("property") && !Parse.User.current().get("network"))
        };
        this.$el.html(JST['src/js/templates/property/new/wizard.jst'](vars));
        this.map = new GMapView({
          wizard: this,
          marker: this.model
        }).render();
        return this;
      };

      PropertyWizardView.prototype.next = function(e) {
        var center,
          _this = this;

        this.$('.error').removeClass('error');
        switch (this.state) {
          case 'address':
            center = this.model.get("center");
            if (center._latitude === 0 && center._longitude === 0) {
              return this.model.trigger("invalid", {
                message: 'invalid_address'
              });
            }
            return Parse.Cloud.run('CheckForUniqueProperty', {
              objectId: this.model.id,
              center: center
            }, {
              success: function() {
                return _this.trigger("address:validated");
              },
              error: function(error) {
                return _this.model.trigger("invalid", error);
              }
            });
          case 'property':
            return this.model.save(this.form.$el.serializeObject().property, {
              success: function(property) {
                return _this.trigger("property:save", property, _this);
              },
              error: function(property, error) {
                return _this.model.trigger("invalid", error);
              }
            });
        }
      };

      PropertyWizardView.prototype.back = function(e) {
        var _this = this;

        if (this.state === 'address') {
          return;
        }
        this.state = 'address';
        this.map.$el.animate({
          left: "0%"
        }, 500);
        this.form.$el.animate({
          left: "150%"
        }, 500, 'swing', function() {
          _this.form.remove();
          _this.form.undelegateEvents();
          return delete _this.form;
        });
        this.$('.back').prop({
          disabled: 'disabled'
        });
        return this.$('.next').html(i18nCommon.actions.next);
      };

      PropertyWizardView.prototype.clear = function() {
        this.$el.empty();
        this.stopListening();
        this.undelegateEvents();
        return delete this;
      };

      return PropertyWizardView;

    })(Parse.View);
  });

}).call(this);
