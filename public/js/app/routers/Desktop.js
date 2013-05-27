(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "backbone", "views/user/Menu", "views/network/Menu", "views/helper/Search"], function($, Parse, UserMenuView, NetworkMenuView, SearchView) {
    var DesktopRouter, _ref;

    return DesktopRouter = (function(_super) {
      __extends(DesktopRouter, _super);

      function DesktopRouter() {
        this.profileShow = __bind(this.profileShow, this);
        this.propertiesPublic = __bind(this.propertiesPublic, this);        _ref = DesktopRouter.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      DesktopRouter.prototype.routes = {
        "": "index",
        "places/:country/:region/:city/:id/:slug": "propertiesPublic",
        "network/set": "networkSet",
        "network/:name": "networkShow",
        "search/*splat": "search",
        "users/:id": "profileShow",
        "users/:id/*splat": "profileShow",
        "account/:category": "accountSettings",
        "*actions": "index"
      };

      DesktopRouter.prototype.initialize = function(options) {
        var _this = this;

        Parse.history.start({
          pushState: true
        });
        this.userView = new UserMenuView().render();
        this.networkView = new NetworkMenuView().render();
        Parse.App.search = new SearchView().render();
        Parse.Dispatcher.on("user:login", function(user) {
          _this.userView.render();
          _this.networkView.render();
          if (Parse.User.current().get("type") === "manager" && !Parse.User.current().get("network")) {
            return require(["views/helper/Alert", 'i18n!nls/property', "views/network/New"], function(Alert, i18nProperty, NewNetworkView) {
              new Alert({
                event: 'no_network',
                type: 'warning',
                fade: true,
                heading: i18nProperty.errors.network_not_set
              });
              Parse.history.navigate("/network/set");
              if (!_this.view || !(_this.view instanceof NewNetworkView)) {
                _this.view = new NewNetworkView({
                  model: Parse.User.current().get("network")
                });
              }
              return _this.view.render();
            });
          } else {
            return Parse.history.loadUrl(location.pathname);
          }
        });
        Parse.Dispatcher.on("user:logout", function() {
          _this.userView.render();
          _this.networkView.render();
          return Parse.history.loadUrl(location.pathname);
        });
        Parse.history.on("route", function(route) {
          $('#search-menu input.search').val("").blur();
          _this.oldConstructor;
          if (_this.view) {
            if (_this.oldConstructor !== _this.view.constructor) {
              _this.oldConstructor = _this.view.constructor;
              _this.view.trigger("view:change");
              _this.view.undelegateEvents();
              _this.view.stopListening();
              return delete _this.view;
            }
          }
        });
        return $(document).on("click", "a", function(e) {
          var href;

          if (e.isDefaultPrevented()) {
            return;
          }
          href = $(this).attr("href");
          if (href === "#" || (href == null)) {
            return;
          }
          if (href.substring(0, 1) === '/' && href.substring(0, 2) !== '//') {
            e.preventDefault();
            return Parse.history.navigate(href, true);
          }
        });
      };

      DesktopRouter.prototype.index = function() {
        var view,
          _this = this;

        view = this.view;
        return require(["views/home/index"], function(HomeIndexView) {
          if (!view || !(view instanceof HomeIndexView)) {
            return _this.view = new HomeIndexView().render();
          }
        });
      };

      DesktopRouter.prototype.search = function(splat) {
        var view,
          _this = this;

        view = this.view;
        return require(["views/activity/index"], function(ActivityIndexView) {
          var vars;

          if (!view || !(view instanceof ActivityIndexView)) {
            vars = _this.deparamAction(splat);
            return _this.view = new ActivityIndexView({
              location: vars.path,
              params: vars.params
            });
          }
        });
      };

      DesktopRouter.prototype.propertiesPublic = function(country, region, city, id, slug) {
        var place,
          _this = this;

        place = "" + city + "--" + region + "--" + country;
        return require(["views/property/Public"], function(PublicPropertyView) {
          return new Parse.Query("Property").get(id, {
            success: function(model) {
              return _this.view = new PublicPropertyView({
                model: model,
                place: place
              }).render();
            },
            error: function(object, error) {
              return _this.accessDenied();
            }
          });
        });
      };

      DesktopRouter.prototype.networkSet = function() {
        var _this = this;

        if (Parse.User.current()) {
          return require(["views/network/New"], function(NewNetworkView) {
            _this.view = new NewNetworkView({
              model: Parse.User.current().get("network")
            });
            return _this.view.render();
          });
        } else {
          return this.signupOrLogin();
        }
      };

      DesktopRouter.prototype.profileShow = function(id, splat) {
        var view,
          _this = this;

        view = this.view;
        return require(["models/Profile", "views/profile/Show"], function(Profile, ShowProfileView) {
          var vars;

          vars = _this.deparamAction(splat);
          if (!view || !(view instanceof ShowProfileView)) {
            if (Parse.User.current().profile && id === Parse.User.current().profile.id) {
              return _this.view = new ShowProfileView({
                path: vars.path,
                params: vars.params,
                model: Parse.User.current().profile,
                current: true
              });
            } else {
              return (new Parse.Query(Profile)).get(id, {
                success: function(obj) {
                  return _this.view = new ShowProfileView({
                    path: vars.path,
                    params: vars.params,
                    model: obj,
                    current: false
                  });
                }
              });
            }
          } else {
            return view.changeSubView(vars.path, vars.params);
          }
        });
      };

      DesktopRouter.prototype.accountSettings = function(category) {
        var _this = this;

        if (Parse.User.current()) {
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
          return Parse.history.navigate("/", true);
        });
      };

      DesktopRouter.prototype.signupOrLogin = function() {
        return require(["views/helper/Alert", 'i18n!nls/common'], function(Alert, i18nCommon) {
          new Alert({
            event: 'routing-canceled',
            type: 'warning',
            fade: true,
            heading: i18nCommon.errors.not_logged_in
          });
          return Parse.history.navigate("/", true);
        });
      };

      return DesktopRouter;

    })(Parse.Router);
  });

}).call(this);
