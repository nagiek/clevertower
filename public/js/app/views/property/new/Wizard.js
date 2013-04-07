(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/Property", "views/helper/Alert", "views/property/new/Map", "i18n!nls/property", "i18n!nls/common", "templates/property/new/map", "templates/property/new/wizard"], function($, _, Parse, Property, Alert, GMapView, i18nProperty, i18nCommon) {
    var PropertyWizardView;
    return PropertyWizardView = (function(_super) {

      __extends(PropertyWizardView, _super);

      function PropertyWizardView() {
        return PropertyWizardView.__super__.constructor.apply(this, arguments);
      }

      PropertyWizardView.prototype.el = '.wizard';

      PropertyWizardView.prototype.state = 'address';

      PropertyWizardView.prototype.events = {
        'click .back': 'back',
        'click .next': 'next',
        'click .cancel': 'cancel'
      };

      PropertyWizardView.prototype.initialize = function() {
        var _this = this;
        _.bindAll(this, 'next', 'back', 'cancel', 'render');
        this.model = new Property({
          user: Parse.User.current()
        });
        this.model.on("invalid", function(error) {
          var args, fn, msg;
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
          return require(["views/property/new/New", "templates/property/new/new"], function(NewPropertyView) {
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
        this.on("property:save", function() {
          _this.remove();
          _this.undelegateEvents();
          delete _this;
          return Parse.history.navigate('/');
        });
        return this.on("wizard:cancel", function() {
          _this.remove();
          _this.undelegateEvents();
          delete _this;
          return Parse.history.navigate('/');
        });
      };

      PropertyWizardView.prototype.render = function() {
        this.$el.html(JST['src/js/templates/property/new/wizard.jst']({
          i18nCommon: i18nCommon
        }));
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
          this.remove();
          return delete this;
        });
        this.$('.back').prop({
          disabled: 'disabled'
        });
        this.$('.next').html(i18nCommon.actions.next);
        return delete this.form;
      };

      PropertyWizardView.prototype.cancel = function(e) {
        this.trigger("wizard:cancel", this);
        this.undelegateEvents();
        this.$el.parent().find("section").show;
        return delete this;
      };

      PropertyWizardView.prototype.remove = function() {
        return this.$el.html('');
      };

      return PropertyWizardView;

    })(Parse.View);
  });

}).call(this);
