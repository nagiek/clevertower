(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "collections/ActivityList", "models/Activity", "models/Property", "models/Unit", "models/Lease", "models/Concierge", "views/helper/Alert", "views/property/new/Map", "views/property/new/New", "views/property/new/Join", "views/property/new/Picture", "views/property/new/Share", "i18n!nls/property", "i18n!nls/common", "templates/property/new/map", "templates/property/new/wizard"], function($, _, Parse, ActivityList, Activity, Property, Unit, Lease, Concierge, Alert, GMapView, NewPropertyView, JoinPropertyView, PicturePropertyView, SharePropertyView, i18nProperty, i18nCommon) {
    var PropertyWizardView, _ref;

    return PropertyWizardView = (function(_super) {
      __extends(PropertyWizardView, _super);

      function PropertyWizardView() {
        this.clear = __bind(this.clear, this);
        this.buttonsForward = __bind(this.buttonsForward, this);
        this.back = __bind(this.back, this);
        this.next = __bind(this.next, this);
        this.manage = __bind(this.manage, this);
        this.join = __bind(this.join, this);        _ref = PropertyWizardView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PropertyWizardView.prototype.className = 'wizard';

      PropertyWizardView.prototype.state = 'address';

      PropertyWizardView.prototype.path = "/";

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
        this.listenTo(Parse.Dispatcher, 'user:logout', function() {
          return Parse.history.navigate("", true);
        });
        this.listenTo(this.model, "invalid", function(error) {
          var args, fn, msg;

          _this.buttonsForward();
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
          return Parse.User.current().get("network").properties.add(property);
        });
        this.on("lease:save", function(lease) {
          var vars;

          vars = {
            lease: lease,
            unit: lease.get("unit"),
            property: lease.get("property")
          };
          Parse.User.current().save(vars);
          return _this.path = "/account/building";
        });
        return this.on("wizard:finish", function() {
          return Parse.history.navigate(_this.path, true);
        });
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
          model: this.model,
          forNetwork: this.forNetwork
        });
        this.listenTo(this.map, "property:join", this.join);
        this.listenTo(this.map, "property:manage", this.manage);
        this.$(".wizard-forms").append(this.map.render().el);
        this.map.renderMap();
        return this;
      };

      PropertyWizardView.prototype.join = function(existingProperty) {
        if (this.state === 'join') {
          return;
        }
        this.$('.error').removeClass('error');
        this.$('button.next').button('loading');
        this.$('button.join').button('loading');
        this.state = 'join';
        this.existingProperty = existingProperty;
        this.form = new JoinPropertyView({
          wizard: this,
          property: this.existingProperty
        });
        this.map.$el.after(this.form.render().el);
        return this.animate('forward');
      };

      PropertyWizardView.prototype.manage = function(existingProperty) {
        var alert, concierge;

        this.$('.error').removeClass('error');
        this.$('button.next').button('loading');
        this.$('button.join').button('loading');
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
        return concierge.save().then(function() {
          return this.trigger("wizard:finish", function(error) {
            return alert.setError(i18nCommon.errors.unknown_error);
          });
        });
      };

      PropertyWizardView.prototype.next = function(e) {
        var attrs, center, data,
          _this = this;

        this.$('.error').removeClass('error');
        this.$('button.next').button('loading');
        this.$('button.join').button('loading');
        switch (this.state) {
          case 'address':
            center = this.model.get("center");
            if (center.latitude === 0 && center.longitude === 0) {
              return this.model.trigger("invalid", {
                message: 'invalid_address'
              });
            } else if (!(this.model.get("thoroughfare") && this.model.get("locality") && (this.model.get("administrative_area_level_1") || this.model.get("administrative_area_level_2")) && this.model.get("country") && this.model.get("postal_code"))) {
              return this.model.trigger("invalid", {
                message: 'insufficient_data'
              });
            } else {
              this.state = 'property';
              this.model.set('title', this.model.get('thoroughfare'));
              if (this.forNetwork) {
                this.form = new NewPropertyView({
                  wizard: this,
                  model: this.model
                });
                this.map.$el.after(this.form.render().el);
                return this.animate('forward');
              } else {
                this.form = new JoinPropertyView({
                  wizard: this,
                  property: this.model
                });
                this.map.$el.after(this.form.render().el);
                return this.animate('forward');
              }
            }
            break;
          case 'property':
            data = this.form.$el.serializeObject();
            if (data.lease) {
              attrs = this.form.model.scrub(data.lease);
              attrs = this.assignAdditionalToLease(data, attrs);
              return this.form.model.save(attrs).then(function(lease) {
                _this.trigger("lease:save", _this.form.model);
                _this.state = 'picture';
                _this.picture = new PicturePropertyView({
                  wizard: _this,
                  model: _this.model
                });
                _this.form.$el.after(_this.picture.render().el);
                return _this.animate('forward');
              }, function(error) {
                return _this.form.model.trigger("invalid", error);
              });
            } else {
              attrs = this.model.scrub(data.property);
              return this.model.save(attrs).then(function(property) {
                _this.trigger("property:save", _this.model);
                _this.state = 'picture';
                _this.picture = new PicturePropertyView({
                  wizard: _this,
                  model: _this.model
                });
                _this.form.$el.after(_this.picture.render().el);
                return _this.animate('forward');
              }, function(error) {
                return _this.model.trigger("invalid", error);
              });
            }
            break;
          case 'picture':
            return this.model.save().then(function(property) {
              _this.state = 'share';
              _this.share = new SharePropertyView({
                wizard: _this,
                model: _this.model
              });
              _this.picture.$el.after(_this.share.render().el);
              return _this.animate('forward');
            }, function(error) {
              return _this.model.trigger("invalid", error);
            });
          case 'share':
            data = this.share.$el.serializeObject();
            attrs = this.model.scrub(data.property);
            return this.model.save(attrs).then(function(property) {
              var activity, activityACL;

              if (data.share.ct === "on" || data.share.ct === "1") {
                activity = new Activity;
                activityACL = new Parse.ACL;
                activityACL.setPublicReadAccess(true);
                activity.save({
                  activity_type: "new_property",
                  "public": true,
                  center: _this.model.get("center"),
                  property: _this.model,
                  network: Parse.User.current().get("network"),
                  title: data.activity.title,
                  profile: Parse.User.current().get("profile"),
                  ACL: activityACL
                }).then(function() {
                  Parse.User.current().activity = Parse.User.current().activity || new ActivityList({}, []);
                  return Parse.User.current().activity.add(activity);
                });
                if (data.share.fb === "on" || data.share.fb === "1") {
                  if (_this.forNetwork) {
                    window.FB.api('me/clevertower:become_a_landlord_in', 'post', {
                      city: window.location.origin + _this.model.city()
                    }, function(response) {
                      return console.log(response);
                    });
                  } else {
                    window.FB.api('me/clevertower:move_into', 'post', {
                      city: window.location.origin + _this.model.city()
                    }, function(response) {
                      return console.log(response);
                    });
                  }
                }
              }
              return _this.trigger("wizard:finish");
            }, function(error) {
              return _this.model.trigger("invalid", error);
            });
          case 'join':
            data = this.form.$el.serializeObject();
            attrs = this.form.model.scrub(data.lease);
            attrs = this.assignAdditionalToLease(data, attrs);
            return this.form.model.save(attrs, {
              success: function(lease) {
                _this.trigger("lease:save", _this.form.model);
                return _this.trigger("wizard:finish");
              },
              error: function(error) {
                return _this.form.model.trigger("invalid", error);
              }
            });
        }
      };

      PropertyWizardView.prototype.back = function(e) {
        if (this.state === 'address') {
          return;
        }
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
            switch (this.state) {
              case "property":
              case "join":
                this.trigger("view:advance");
                this.$('.back').removeProp("disabled");
                this.map.$el.animate({
                  left: "-150%"
                }, 500);
                return this.form.$el.animate({
                  left: "0"
                }, 500, 'swing', this.buttonsForward);
              case "picture":
                this.form.$el.animate({
                  left: "-150%"
                }, 500);
                return this.picture.$el.animate({
                  left: "0"
                }, 500, 'swing', this.buttonsForward);
              case "share":
                this.$('.next').html(i18nCommon.actions.finish);
                this.picture.$el.animate({
                  left: "-150%"
                }, 500);
                return this.share.$el.animate({
                  left: "0"
                }, 500, 'swing', this.buttonsForward);
            }
            break;
          case 'backward':
            switch (this.state) {
              case "property":
              case "join":
                this.trigger("view:retreat");
                this.map.$el.animate({
                  left: "0%"
                }, 500);
                this.form.$el.animate({
                  left: "150%"
                }, 500, 'swing', function() {
                  _this.form.clear();
                  return _this.$('.back').prop("disabled", true);
                });
                delete this.existingProperty;
                this.state = 'address';
                return this.$('.back').prop("disabled", true);
              case "picture":
                this.form.$el.animate({
                  left: "0%"
                }, 500);
                this.picture.$el.animate({
                  left: "150%"
                }, 500, 'swing', this.picture.clear);
                return this.state = 'property';
              case "share":
                this.$('.next').html(i18nCommon.actions.next);
                this.picture.$el.animate({
                  left: "0%"
                }, 500);
                this.share.$el.animate({
                  left: "150%"
                }, 500, 'swing', this.share.clear);
                return this.state = 'picture';
            }
        }
      };

      PropertyWizardView.prototype.buttonsForward = function() {
        this.$('.next').button('complete');
        this.$('.join').button('complete');
        switch (this.state) {
          case "share":
            this.$('.next').html(i18nCommon.actions.finish);
            return this.$('.join').html(i18nCommon.actions.join);
          default:
            this.$('.next').html(i18nCommon.actions.next);
            return this.$('.join').html(i18nCommon.actions.join);
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
