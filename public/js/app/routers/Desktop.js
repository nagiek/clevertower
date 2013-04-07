(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "backbone", "views/user/UserMenu"], function($, Parse, UserMenuView) {
    var DesktopRouter;
    return DesktopRouter = (function(_super) {

      __extends(DesktopRouter, _super);

      function DesktopRouter() {
        this.propertiesShow = __bind(this.propertiesShow, this);

        this.propertiesNew = __bind(this.propertiesNew, this);

        this.index = __bind(this.index, this);
        return DesktopRouter.__super__.constructor.apply(this, arguments);
      }

      DesktopRouter.prototype.routes = {
        "": "index",
        "properties/new": "propertiesNew",
        "properties/:id": "propertiesShow",
        "properties/:id/*splat": "propertiesShow",
        "users/:id": "profileShow",
        "users/:id/edit": "profileEdit",
        "account/:category": "accountSettings",
        "*actions": "index"
      };

      DesktopRouter.prototype.initialize = function(options) {
        Parse.history.start({
          pushState: true
        });
        new UserMenuView();
        return $(document).on("click", "a", function(e) {
          var href, protocol;
          href = $(this).attr("href");
          if (href === "#" || !(href != null)) {
            return;
          }
          protocol = this.protocol + "//";
          if (href.slice(protocol.length) !== protocol) {
            e.preventDefault();
            return Parse.history.navigate(href, true);
          }
        });
      };

      DesktopRouter.prototype.index = function() {
        var user,
          _this = this;
        user = Parse.User.current();
        if (user) {
          if (user.get("type") === "manager") {
            return require(["views/property/Manage"], function(ManagePropertiesView) {
              if (!_this.view || !(_this.view instanceof ManagePropertiesView)) {
                _this.view = new ManagePropertiesView;
              }
              return _this.view.render();
            });
          } else {
            return require(["views/property/Manage"], function(ManagePropertiesView) {
              if (!_this.view || !(_this.view instanceof ManagePropertiesView)) {
                _this.view = new ManagePropertiesView;
              }
              return _this.view.render();
            });
          }
        } else {
          return $('#main').html('<h1>Cover page goes here</h1>');
        }
      };

      DesktopRouter.prototype.propertiesNew = function() {
        var _this = this;
        if (Parse.User.current()) {
          return require(["views/property/Manage"], function(ManagePropertiesView) {
            if (!_this.view || !(_this.view instanceof ManagePropertiesView)) {
              _this.view = new ManagePropertiesView;
            }
            _this.view.render();
            return _this.view.newProperty();
          });
        } else {
          return this.signupOrLogin();
        }
      };

      DesktopRouter.prototype.propertiesShow = function(id, splat) {
        var _this = this;
        if (Parse.User.current()) {
          return require(["views/property/Show"], function(PropertyView) {
            var vars;
            if (!_this.view || !(_this.view instanceof PropertyView)) {
              return require(["models/Property", "collections/property/PropertyList"], function(Property, PropertyList) {
                var combo, model, vars;
                if (Parse.User.current().properties) {
                  if (model = Parse.User.current().properties.get(id)) {
                    combo = _this.deparamAction(splat);
                    vars = {
                      model: model,
                      path: combo.path,
                      params: combo.params
                    };
                    $('#main').html('<div id="property"></div>');
                    return _this.view = new PropertyView(vars);
                  } else {
                    return new Parse.Query("Property").get(id, {
                      success: function(model) {
                        Parse.User.current().properties.add(model);
                        vars = _this.deparamAction(splat);
                        vars.model = model;
                        $('#main').html('<div id="property"></div>');
                        return _this.view = new PropertyView(vars);
                      },
                      error: function(object, error) {
                        return _this.accessDenied();
                      }
                    });
                  }
                } else {
                  if (!Parse.User.current().properties) {
                    Parse.User.current().properties = new PropertyList;
                  }
                  return new Parse.Query("Property").get(id, {
                    success: function(model) {
                      Parse.User.current().properties.add(model);
                      vars = _this.deparamAction(splat);
                      vars.model = model;
                      $('#main').html('<div id="property"></div>');
                      return _this.view = new PropertyView(vars);
                    },
                    error: function(object, error) {
                      return _this.accessDenied();
                    }
                  });
                }
              });
            } else {
              vars = _this.deparamAction(splat);
              return _this.view.changeSubView(vars.path, vars.params);
            }
          });
        } else {
          return this.signupOrLogin();
        }
      };

      DesktopRouter.prototype.profileShow = function(id) {
        var _this = this;
        return require(["models/Profile", "views/profile/Show"], function(Profile, ShowProfileView) {
          if (Parse.User.current().profile && id === Parse.User.current().profile.id) {
            _this.view = new ShowProfileView({
              model: Parse.User.current().profile,
              current: true
            });
            return _this.view.render();
          } else {
            return (new Parse.Query(Profile)).get(id, {
              success: function(obj) {
                _this.view = new ShowProfileView({
                  model: obj,
                  current: false
                });
                return _this.view.render();
              }
            });
          }
        });
      };

      DesktopRouter.prototype.profileEdit = function(id) {
        var _this = this;
        return require(["models/Profile", "views/profile/Edit"], function(Profile, EditProfileView) {
          if (Parse.User.current().profile && id === Parse.User.current().profile.id) {
            _this.view = new EditProfileView({
              model: Parse.User.current().profile,
              current: true
            });
            return _this.view.render();
          } else {
            return (new Parse.Query(Profile)).get(id, {
              success: function(obj) {
                _this.view = new EditProfileView({
                  model: obj,
                  current: false
                });
                return _this.view.render();
              }
            });
          }
        });
      };

      DesktopRouter.prototype.accountSettings = function(category) {
        var _this = this;
        if (Parse.User.current().authenticated()) {
          if (category === 'edit') {
            return require(["views/profile/edit"], function(UserSettingsView) {
              return _this.view = new UserSettingsView({
                model: Parse.User.current().profile,
                current: true
              }).render();
            });
          } else {
            return require(["views/user/" + category], function(UserSettingsView) {
              return _this.view = new UserSettingsView({
                model: Parse.User.current()
              }).render();
            });
          }
        } else {
          return this.signupOrLogin();
        }
      };

      DesktopRouter.prototype.deparamAction = function(splat) {
        var ary, combo;
        ary = splat ? splat.split('?') : new Array('');
        return combo = {
          path: ary[0],
          params: ary[1] ? this.deparam(ary[1]) : {}
        };
      };

      DesktopRouter.prototype.deparam = function(querystring) {
        var combo, d, pair, params, _i, _len;
        querystring = querystring.split('&');
        params = {};
        d = decodeURIComponent;
        for (_i = 0, _len = querystring.length; _i < _len; _i++) {
          combo = querystring[_i];
          pair = combo.split('=');
          params[d(pair[0])] = d(pair[1]);
        }
        return params;
      };

      DesktopRouter.prototype.accessDenied = function() {
        return require(["views/helper/Alert", 'i18n!nls/common'], function(Alert, i18nCommon) {
          new Alert({
            event: 'access-denied',
            type: 'error',
            fade: true,
            heading: i18nCommon.errors.access_denied,
            message: i18nCommon.errors.no_permission
          });
          return Parse.history.navigate("/");
        });
      };

      DesktopRouter.prototype.signupOrLogin = function() {
        return require(["views/helper/Alert", 'i18n!nls/common'], function(Alert, i18nCommon) {
          new Alert({
            event: 'access-denied',
            type: 'error',
            fade: true,
            heading: i18nCommon.errors.access_denied,
            message: i18nCommon.errors.no_permission
          });
          return Parse.history.navigate("/");
        });
      };

      return DesktopRouter;

    })(Parse.Router);
  });

}).call(this);
