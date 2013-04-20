(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "backbone", "views/user/Menu", "views/network/Menu", "views/helper/Search"], function($, Parse, UserMenuView, NetworkMenuView, SearchView) {
    var DesktopRouter;
    return DesktopRouter = (function(_super) {

      __extends(DesktopRouter, _super);

      function DesktopRouter() {
        return DesktopRouter.__super__.constructor.apply(this, arguments);
      }

      DesktopRouter.prototype.routes = {
        "": "index",
        "network/set": "networkSet",
        "network/:name": "networkShow",
        "users/:id": "profileShow",
        "users/:id/edit": "profileEdit",
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
        new SearchView().render();
        Parse.Dispatcher.on("user:login", function(user) {
          return Parse.User.current().setup().then(function() {
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
                if (!_this.view || !(_this.view instanceof NetworkFormView)) {
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
        });
        Parse.Dispatcher.on("user:logout", function() {
          _this.userView.render();
          _this.networkView.render();
          return Parse.history.loadUrl(location.pathname);
        });
        Parse.history.on("route", function() {
          $('#search').val('').blur();
          if (_this.view) {
            _this.view.undelegateEvents();
            return delete _this.view;
          }
        });
        return $(document).on("click", "a", function(e) {
          var href;
          href = $(this).attr("href");
          if (href === "#" || !(href != null)) {
            return;
          }
          if (href.substring(0, 1) === '/' && href.substring(0, 2) !== '//') {
            e.preventDefault();
            return Parse.history.navigate(href, true);
          }
        });
      };

      DesktopRouter.prototype.index = function() {
        if (Parse.User.current()) {
          return $('#main').html("<h1>News Feed</h1>\n<div class=\"row\">\n  <div class=\"span8\">\n\n  </div>\n  <div class=\"span4\">\n    <!-- if user.get('type') is 'manager' then  -->\n    <ul class=\"nav nav-list well\"><li><a href=\"/network/set\">Set up network</a></li></ul>\n  </div>\n</div>");
        } else {
          return $('#main').html('<h1>Splash page</h1>');
        }
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
