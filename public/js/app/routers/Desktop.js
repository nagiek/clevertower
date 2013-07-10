(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "backbone", "views/user/UserMenu", "views/user/NavMenu", "views/helper/Search"], function($, Parse, UserMenuView, NavMenuView, SearchView) {
    var DesktopRouter, _ref;

    return DesktopRouter = (function(_super) {
      __extends(DesktopRouter, _super);

      function DesktopRouter() {
        this.profileShow = __bind(this.profileShow, this);
        this.propertiesPublic = __bind(this.propertiesPublic, this);
        this.propertiesManage = __bind(this.propertiesManage, this);
        this.propertiesNew = __bind(this.propertiesNew, this);
        this.networkNew = __bind(this.networkNew, this);        _ref = DesktopRouter.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      DesktopRouter.prototype.routes = {
        "": "index",
        "properties/new": "propertiesNew",
        "places/:country/:region/:city/:id/:slug": "propertiesPublic",
        "manage": "propertiesManage",
        "manage/*splat": "propertiesManage",
        "network/new": "networkNew",
        "network/:name": "networkShow",
        "search": "search",
        "search/*splat": "search",
        "users/:id": "profileShow",
        "users/:id/*splat": "profileShow",
        "notifications": "notifications",
        "account/setup": "accountSetup",
        "account/*splat": "accountSettings",
        "oauth2callback": "oauth2callback",
        "*actions": "index"
      };

      DesktopRouter.prototype.initialize = function(options) {
        var _this = this;

        Parse.history.start({
          pushState: true
        });
        new UserMenuView().render();
        new NavMenuView().render();
        Parse.App.search = new SearchView().render();
        this.listenTo(Parse.Dispatcher, "user:login", function(user) {
          if (!(Parse.User.current().get("network") || Parse.User.current().get("property"))) {
            return _this.accountSetup();
          } else {
            return Parse.history.loadUrl(location.pathname);
          }
        });
        this.listenTo(Parse.Dispatcher, "user:logout", function() {
          return Parse.history.loadUrl(location.pathname);
        });
        this.listenTo(Parse.history, "route", function(route) {
          $('#search-menu input.search').val("").blur();
          if (_this.view) {
            if (_this.oldConstructor !== _this.view.constructor) {
              _this.oldConstructor = _this.view.constructor;
              return _this.view.trigger("view:change");
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
            }).render();
          }
        });
      };

      DesktopRouter.prototype.networkNew = function() {
        var view,
          _this = this;

        view = this.view;
        return require(["views/network/New"], function(NewNetworkView) {
          _this.view = new NewNetworkView();
          _this.view.setElement("#main");
          return _this.view.render();
        });
      };

      DesktopRouter.prototype.propertiesNew = function() {
        var view,
          _this = this;

        view = this.view;
        return require(["views/property/new/Wizard"], function(PropertyWizard) {
          if (!view || !(view instanceof PropertyWizard)) {
            _this.view = new PropertyWizard({
              forNetwork: false
            });
            _this.view.setElement("#main");
            return _this.view.render();
          }
        });
      };

      DesktopRouter.prototype.propertiesManage = function(splat) {
        var vars, view,
          _this = this;

        view = this.view;
        vars = this.deparamAction(splat);
        if (Parse.User.current().get("property").get("mgrRole")) {
          return require(["views/property/Manage"], function(PropertyView) {
            if (!view || !(view instanceof PropertyView)) {
              vars.model = Parse.User.current().get("property");
              return _this.view = new PropertyView(vars);
            } else {
              return view.changeSubView(vars.path, vars.params);
            }
          });
        } else {
          return require(["views/lease/Manage"], function(LeaseView) {
            if (!view || !(view instanceof LeaseView)) {
              vars.model = Parse.User.current().get("lease");
              return _this.view = new LeaseView(vars);
            } else {
              return view.changeSubView(vars.path, vars.params);
            }
          });
        }
      };

      DesktopRouter.prototype.propertiesPublic = function(country, region, city, id, slug) {
        var place,
          _this = this;

        place = "" + city + "--" + region + "--" + country;
        return require(["models/Property", "views/property/Public"], function(Property, PublicPropertyView) {
          return new Parse.Query(Property).get(id, {
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

      DesktopRouter.prototype.profileShow = function(id, splat) {
        var view,
          _this = this;

        view = this.view;
        return require(["models/Profile", "views/profile/Show"], function(Profile, ShowProfileView) {
          var vars;

          vars = _this.deparamAction(splat);
          if (!view || !(view instanceof ShowProfileView)) {
            if (Parse.User.current() && Parse.User.current().get("profile") && id === Parse.User.current().get("profile").id) {
              return _this.view = new ShowProfileView({
                path: vars.path,
                params: vars.params,
                model: Parse.User.current().get("profile"),
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

      DesktopRouter.prototype.accountSetup = function() {
        var _this = this;

        if (Parse.User.current()) {
          return require(["views/user/Setup"], function(NewNetworkView) {
            _this.view = new NewNetworkView({
              model: Parse.User.current().get("network")
            });
            return _this.view.render();
          });
        } else {
          return this.signupOrLogin();
        }
      };

      DesktopRouter.prototype.accountSettings = function(splat) {
        var view,
          _this = this;

        view = this.view;
        if (splat === 'edit') {
          return require(["views/profile/edit"], function(EditProfileView) {
            return _this.view = new EditProfileView({
              model: Parse.User.current().get("profile"),
              current: true
            }).render();
          });
        } else {
          return require(["views/user/Account"], function(UserAccountView) {
            var vars;

            vars = _this.deparamAction(splat);
            if (!view || !(view instanceof UserAccountView)) {
              return _this.view = new UserAccountView(vars);
            } else {
              return view.changeSubView(vars.path, vars.params);
            }
          });
        }
      };

      DesktopRouter.prototype.notifications = function() {
        var _this = this;

        if (Parse.User.current()) {
          return require(["views/notification/All"], function(AllNotificationsView) {
            return _this.view = new AllNotificationsView().render();
          });
        } else {
          return this.signupOrLogin();
        }
      };

      DesktopRouter.prototype.oauth2callback = function() {
        var vars;

        if (Parse.User.current()) {
          vars = this.deparam(window.location.hash.substring(1));
          if (!vars.error) {
            return $.ajax("https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=" + vars.access_token, {
              beforeSend: function(jqXHR, settings) {},
              success: function(res) {
                if (res.audience && res.audience === window.GCLIENT_ID) {
                  res.access_token = vars.access_token;
                  res.expires_in += new Date().getTime() / 1000;
                  return Parse.User.current().save({
                    googleAuthData: res
                  }).then(function() {
                    return Parse.history.navigate(vars.state, true);
                  });
                } else {
                  require(["views/helper/Alert", 'i18n!nls/common'], function(Alert, i18nCommon) {
                    return new Alert({
                      event: 'access-denied',
                      type: 'error',
                      fade: true,
                      heading: i18nCommon.oauth.error,
                      message: i18nCommon.oauth.unverified_token
                    });
                  });
                  return Parse.history.navigate(vars.state, true);
                }
              }
            });
          } else {
            require(["views/helper/Alert", 'i18n!nls/common'], function(Alert, i18nCommon) {
              return new Alert({
                event: 'access-denied',
                type: 'error',
                fade: true,
                heading: i18nCommon.oauth.error,
                message: i18nCommon.oauth[vars.error]
              });
            });
            return Parse.history.navigate(vars.state, true);
          }
        } else {
          return this.signupOrLogin();
        }
      };

      DesktopRouter.prototype.deparamAction = function(splat) {
        var ary, combo, indexOfHash;

        if (!splat) {
          return {
            path: "",
            params: {}
          };
        }
        indexOfHash = splat.indexOf("#");
        if (indexOfHash >= 0) {
          splat = splat.substr(0, indexOfHash);
        }
        ary = splat.indexOf("?") >= 0 ? splat.split('?') : new Array(splat);
        return combo = {
          path: String(ary[0]),
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
