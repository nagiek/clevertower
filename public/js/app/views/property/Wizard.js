(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/Address", "models/Property", "views/address/Map", "i18n!nls/address", "i18n!nls/property", "i18n!nls/common", "templates/address/map", "templates/property/wizard"], function($, _, Parse, Address, Property, GMapView, i18nAddress, i18nProperty, i18nCommon) {
    var PropertyWizardView;
    return PropertyWizardView = (function(_super) {

      __extends(PropertyWizardView, _super);

      function PropertyWizardView() {
        return PropertyWizardView.__super__.constructor.apply(this, arguments);
      }

      PropertyWizardView.prototype.el = "#form .wizard";

      PropertyWizardView.prototype.state = 'address';

      PropertyWizardView.prototype.events = {
        'click .back': 'back',
        'click .next': 'next',
        'click .cancel': 'cancel'
      };

      PropertyWizardView.prototype.initialize = function() {
        var _this = this;
        this.address = new Address;
        this.property = new Property({
          address: this.address,
          user: Parse.User.current()
        });
        this.$el.html(JST["src/js/templates/address/map.jst"]({
          i18nAddress: i18nAddress,
          i18nCommon: i18nCommon
        }));
        this.$el.append(JST["src/js/templates/property/wizard.jst"]({
          i18nCommon: i18nCommon
        }));
        this.map = new GMapView({
          wizard: this,
          address: this.address
        });
        this.on("property:save", function() {
          _this.remove();
          _this.undelegateEvents();
          delete _this;
          return Parse.history.navigate('/');
        });
        this.on("wizard:cancel", function() {
          _this.remove();
          _this.undelegateEvents();
          delete _this;
          return Parse.history.navigate('/');
        });
        _.bindAll(this, 'next', 'back', 'cancel');
        return this.render();
      };

      PropertyWizardView.prototype.next = function(e) {
        var _this = this;
        switch (this.state) {
          case 'address':
            return this.address.save({
              success: function(address) {
                _this.state = 'property';
                return require(["views/property/New", "templates/property/new"], function(NewPropertyView) {
                  _this.$el.find('.address-form').after('<form class="property-form"></form>');
                  _this.form = new NewPropertyView({
                    wizard: _this,
                    model: _this.property
                  });
                  _this.map.$el.animate({
                    left: "-150%"
                  }, 500);
                  _this.form.$el.show().animate({
                    left: "0"
                  }, 500);
                  _this.$el.find('.back').prop({
                    disabled: false
                  });
                  return _this.$el.find('.next').html(i18nCommon.actions.save);
                });
              },
              error: function(address, error) {
                _this.$el.find('.alert-error').html(i18nAddress.errors[error.message]).show();
                return _this.$el.find('#address-search-group').addClass('error');
              }
            });
          case 'property':
            return this.property.save(this.form.$el.serializeObject().property, {
              success: function(property) {
                return _this.trigger("property:save", property, _this);
              },
              error: function(property, error) {
                _this.$el.find('.alert-error').html(i18nProperty.errors[error.message]).show();
                _this.$el.find('.error').removeClass('error');
                switch (error.message) {
                  case 'title_missing':
                    return _this.$el.find('#property-title-group').addClass('error');
                }
              }
            });
        }
      };

      PropertyWizardView.prototype.back = function(e) {
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
        this.$el.find('.back').prop({
          disabled: 'disabled'
        });
        this.$el.find('.next').html(i18nCommon.actions.next);
        return delete this.form;
      };

      PropertyWizardView.prototype.cancel = function(e) {
        this.trigger("wizard:cancel", this);
        this.undelegateEvents();
        this.$el.hide();
        this.$el.parent().find("section").show;
        return delete this;
      };

      PropertyWizardView.prototype.render = function() {
        return this.map.$el.show();
      };

      return PropertyWizardView;

    })(Parse.View);
  });

}).call(this);
