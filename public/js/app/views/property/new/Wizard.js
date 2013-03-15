(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/Property", "views/property/new/Map", "i18n!nls/property", "i18n!nls/common", "templates/property/new/map", "templates/property/new/wizard"], function($, _, Parse, Property, GMapView, i18nProperty, i18nCommon) {
    var PropertyWizardView;
    return PropertyWizardView = (function(_super) {

      __extends(PropertyWizardView, _super);

      function PropertyWizardView() {
        return PropertyWizardView.__super__.constructor.apply(this, arguments);
      }

      PropertyWizardView.prototype.el = '#form';

      PropertyWizardView.prototype.state = 'address';

      PropertyWizardView.prototype.events = {
        'click .back': 'back',
        'click .next': 'next',
        'click .cancel': 'cancel'
      };

      PropertyWizardView.prototype.initialize = function() {
        var _this = this;
        this.model = new Property({
          user: Parse.User.current()
        });
        this.$el.html(JST['src/js/templates/property/new/wizard.jst']({
          i18nCommon: i18nCommon
        })).find('.wizard-forms').html(JST["src/js/templates/property/new/map.jst"]({
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        }));
        this.map = new GMapView({
          wizard: this,
          marker: this.model
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
        return _.bindAll(this, 'next', 'back', 'cancel');
      };

      PropertyWizardView.prototype.next = function(e) {
        var center,
          _this = this;
        switch (this.state) {
          case 'address':
            center = this.model.get("center");
            if (center._latitude === 0 && center._longitude === 0) {
              return this.$('.alert-error').html(i18nProperty.errors.invalid_address).show();
            }
            this.state = 'property';
            return Parse.Cloud.run('CheckForUniqueProperty', {
              objectId: this.model.id,
              center: center
            }, {
              success: function() {
                return require(["views/property/new/New", "templates/property/new/new"], function(NewPropertyView) {
                  _this.$('.address-form').after('<form class="property-form span12"></form>');
                  _this.form = new NewPropertyView({
                    wizard: _this,
                    model: _this.model
                  });
                  _this.map.$el.animate({
                    left: "-150%"
                  }, 500);
                  _this.form.$el.show().animate({
                    left: "0"
                  }, 500);
                  _this.$('.back').prop({
                    disabled: false
                  });
                  _this.$('.next').html(i18nCommon.actions.save);
                  return _this.$('.alert-error').hide();
                });
              },
              error: function(error) {
                var args, fn;
                _this.state = 'address';
                args = error.message.split(":");
                fn = args.pop();
                _this.$('.alert-error').html(i18nProperty.errors[fn](args[0])).show();
                return _this.$('#address-search-group').addClass('error');
              }
            });
          case 'property':
            return this.model.save(this.form.$el.serializeObject().property, {
              success: function(property) {
                return _this.trigger("property:save", property, _this);
              },
              error: function(property, error) {
                _this.$('.alert-error').html(i18nProperty.errors[error.message]).show();
                _this.$('.error').removeClass('error');
                switch (error.message) {
                  case 'title_missing':
                    return _this.$('#property-title-group').addClass('error');
                }
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
