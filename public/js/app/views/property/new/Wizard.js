(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/Property", "models/Unit", "models/Lease", "views/helper/Alert", "views/property/new/Map", "i18n!nls/property", "i18n!nls/common", "templates/property/new/map", "templates/property/new/wizard"], function($, _, Parse, Property, Unit, Lease, Alert, GMapView, i18nProperty, i18nCommon) {
    var PropertyWizardView, _ref;

    return PropertyWizardView = (function(_super) {
      __extends(PropertyWizardView, _super);

      function PropertyWizardView() {
        this.clear = __bind(this.clear, this);
        this.back = __bind(this.back, this);
        this.next = __bind(this.next, this);
        this.manage = __bind(this.manage, this);
        this.join = __bind(this.join, this);        _ref = PropertyWizardView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PropertyWizardView.prototype.className = 'wizard';

      PropertyWizardView.prototype.state = 'address';

      PropertyWizardView.prototype.events = {
        'click .back': 'back',
        'click .next': 'next'
      };

      PropertyWizardView.prototype.initialize = function(attrs) {
        var _this = this;

        this.forNetwork = attrs && attrs.forNetwork ? true : false;
        this.model = new Property;
        if (this.forNetwork) {
          this.model.set("network", Parse.User.current().get("network"));
        }
        this.map = new GMapView({
          wizard: this,
          model: this.model,
          forNetwork: this.forNetwork
        });
        this.listenTo(this.map, "property:join", this.join);
        this.listenTo(this.map, "property:manage", this.manage);
        this.listenTo(Parse.Dispatcher, 'user:logout', function() {
          Parse.history.navigate("/", true);
          return this.clear();
        });
        this.listenTo(this.model, "invalid", function(error) {
          var args, fn, msg;

          _this.$('button.next').removeProp("disabled");
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
        this.on("property:save", function(property) {
          Parse.User.current().get("network").properties.add(property);
          return Parse.history.navigate("/", {
            trigger: true
          });
        });
        return this.on("lease:save", function(lease, isNew) {
          var vars;

          vars = {
            lease: lease,
            unit: lease.get("unit"),
            property: lease.get("property"),
            mgrOfProp: isNew
          };
          Parse.User.current().set(vars);
          Parse.history.navigate("/account/building", true);
          return _this.clear();
        });
      };

      PropertyWizardView.prototype.render = function() {
        var vars;

        vars = {
          i18nCommon: i18nCommon,
          setup: !Parse.User.current() || (!Parse.User.current().get("property") && !Parse.User.current().get("network"))
        };
        this.$el.html(JST['src/js/templates/property/new/wizard.jst'](vars));
        this.$el.find(".wizard-forms").append(this.map.render().el);
        this.map.renderMap();
        return this;
      };

      PropertyWizardView.prototype.join = function(existingProperty) {
        var _this = this;

        if (this.state === 'join') {
          return;
        }
        this.$('.error').removeClass('error');
        this.$('button.next').prop("disabled", true);
        this.$('button.join').prop("disabled", true);
        this.state = 'join';
        this.existingProperty = existingProperty;
        return require(["views/property/new/Join"], function(JoinPropertyView) {
          _this.form = new JoinPropertyView({
            wizard: _this,
            property: _this.existingProperty
          });
          _this.map.$el.after(_this.form.render().el);
          return _this.animate('forward');
        });
      };

      PropertyWizardView.prototype.manage = function(existingProperty) {
        var _this = this;

        this.$('.error').removeClass('error');
        this.$('button.next').prop("disabled", true);
        this.$('button.join').prop("disabled", true);
        return require(["models/Concierge"], function(Concierge) {
          var alert, concierge;

          concierge = new Concierge({
            property: existingProperty,
            profile: Parse.User.current().get("profile"),
            state: 'pending'
          });
          alert = new Alert({
            event: 'model-save',
            fade: false,
            message: i18nCommon.actions.request_sent,
            type: 'error'
          });
          return concierge.save().then(_this.clear, function(error) {
            return alert.setError(i18nCommon.errors.unknown_error);
          });
        });
      };

      PropertyWizardView.prototype.next = function(e) {
        var attrs, center, data,
          _this = this;

        this.$('.error').removeClass('error');
        this.$('button.next').prop("disabled", true);
        this.$('button.join').prop("disabled", true);
        switch (this.state) {
          case 'address':
            center = this.model.get("center");
            if (center._latitude === 0 && center._longitude === 0) {
              return this.model.trigger("invalid", {
                message: 'invalid_address'
              });
            }
            if (this.model.get("thoroughfare") === '' || this.model.get("locality") === '' || this.model.get("administrative_area_level_1") === '' || this.model.get("country") === '' || this.model.get("postal_code") === '') {
              return this.model.trigger("invalid", {
                message: 'insufficient_data'
              });
            }
            this.state = 'property';
            this.model.set('title', this.model.get('thoroughfare'));
            if (this.forNetwork) {
              return require(["views/property/new/New"], function(NewPropertyView) {
                _this.form = new NewPropertyView({
                  wizard: _this,
                  model: _this.model
                });
                _this.map.$el.after(_this.form.render().el);
                return _this.animate('forward');
              });
            } else {
              return require(["views/property/new/Join"], function(JoinPropertyView) {
                _this.form = new JoinPropertyView({
                  wizard: _this,
                  property: _this.model
                });
                _this.map.$el.after(_this.form.render().el);
                return _this.animate('forward');
              });
            }
            break;
          case 'property':
            data = this.form.$el.serializeObject();
            if (data.lease) {
              attrs = this.form.model.scrub(data.lease);
              attrs = this.assignAdditionalToLease(data, attrs);
              return this.form.model.save(attrs, {
                success: function(lease) {
                  return _this.trigger("lease:save", _this.form.model, false);
                },
                error: function(lease, error) {
                  _this.form.model.trigger("invalid", error);
                  return console.log(error);
                }
              });
            } else {
              attrs = this.model.scrub(data.property);
              return this.model.save(attrs, {
                success: function(property) {
                  return _this.trigger("property:save", _this.model);
                },
                error: function(property, error) {
                  _this.model.trigger("invalid", error);
                  return console.log(error);
                }
              });
            }
            break;
          case 'join':
            data = this.form.$el.serializeObject();
            attrs = this.form.model.scrub(data.lease);
            attrs = this.assignAdditionalToLease(data, attrs);
            return this.form.model.save(attrs, {
              success: function(lease) {
                return _this.trigger("lease:save", _this.form.model, true);
              },
              error: function(lease, error) {
                _this.form.model.trigger("invalid", error);
                return console.log(error);
              }
            });
        }
      };

      PropertyWizardView.prototype.back = function(e) {
        if (this.state === 'address') {
          return;
        }
        delete this.existingProperty;
        this.$('button.join').removeProp("disabled");
        this.state = 'address';
        return this.animate('backward');
      };

      PropertyWizardView.prototype.assignAdditionalToLease = function(data, attrs) {
        var email, property, unit, userValid, _i, _len, _ref1;

        if (this.existingProperty) {
          unit = new Unit(data.unit.attributes);
          unit.set("property", this.existingProperty);
          attrs.unit = unit;
          attrs.property = this.existingProperty;
        } else {
          property = this.model;
          property.set(this.model.scrub(data.property));
          unit = new Unit(data.unit.attributes);
          unit.set("property", property);
          attrs.unit = unit;
          attrs.property = property;
        }
        userValid = true;
        if (data.emails && data.emails !== '') {
          attrs.emails = [];
          _ref1 = data.emails.split(",");
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            email = _ref1[_i];
            email = _.str.trim(email);
            userValid = !Parse.User.prototype.validate({
              email: email
            }) ? true : false;
            if (!userValid) {
              break;
            }
            attrs.emails.push(email);
          }
        }
        if (!userValid) {
          this.$('.emails-group').addClass('error');
          this.model.trigger("invalid", {
            message: 'tenants_incorrect'
          });
          return false;
        } else {
          return attrs;
        }
      };

      PropertyWizardView.prototype.animate = function(dir) {
        var _this = this;

        switch (dir) {
          case 'forward':
            this.map.$el.animate({
              left: "-150%"
            }, 500);
            return this.form.$el.animate({
              left: "0"
            }, 500, 'swing', function() {
              _this.$('.next').removeProp("disabled");
              _this.$('.next').html(i18nCommon.actions.save);
              return _this.$('.back').prop({
                disabled: false
              });
            });
          case 'backward':
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
            return this.$('.next').html(i18nCommon.actions.create);
        }
      };

      PropertyWizardView.prototype.clear = function() {
        this.stopListening();
        this.undelegateEvents();
        return delete this;
      };

      return PropertyWizardView;

    })(Parse.View);
  });

}).call(this);
