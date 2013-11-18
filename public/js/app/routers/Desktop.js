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
        this.tenantsNew = __bind(this.tenantsNew, this);
        this.leasesNew = __bind(this.leasesNew, this);
        this.listingsNew = __bind(this.listingsNew, this);
        this.propertiesPublic = __bind(this.propertiesPublic, this);
        this.propertiesManage = __bind(this.propertiesManage, this);
        this.propertiesNew = __bind(this.propertiesNew, this);
        this.movein = __bind(this.movein, this);
        this.insideManage = __bind(this.insideManage, this);
        this.networkNew = __bind(this.networkNew, this);
        this.activityShow = __bind(this.activityShow, this);        _ref = DesktopRouter.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      DesktopRouter.prototype.routes = {
        "": "index",
        "places/:country/:region/:city/:id/:slug": "propertiesPublic",
        "posts/:id": "activityShow",
        "outside/*splat": "outside",
        "outside*splat": "outside",
        "network/new": "networkNew",
        "listings/new": "listingsNew",
        "leases/new": "leasesNew",
        "tenants/new": "tenantsNew",
        "movein": "movein",
        "properties/new": "propertiesNew",
        "properties/:id": "propertiesManage",
        "properties/:id/*splat": "propertiesManage",
        "properties/:id/*splat": "propertiesManage",
        "inside/*splat": "insideManage",
        "inside": "insideManage",
        "users/:id": "profileShow",
        "users/:id/*splat": "profileShow",
        "notifications": "notifications",
        "account/setup": "accountSetup",
        "account/signup": "signup",
        "account/reset_password": "resetPassword",
        "account/login": "login",
        "account/logout": "logout",
        "account/*splat": "accountSettings",
        "oauth2callback": "oauth2callback"
      };

      DesktopRouter.prototype.initialize = function(options) {
        var _this = this;

        Parse.history.start({
          pushState: true
        });
        new UserMenuView().render();
        new NavMenuView().render();
        Parse.App.search = new SearchView().render();
        $("#sidebar-toggle").click(function() {
          return $("body").toggleClass("active");
        });
        this.listenTo(Parse.Dispatcher, "user:login", function() {
          if (Parse.User.current().get("network") || Parse.User.current().get("property")) {
            return Parse.history.loadUrl(location.pathname);
          } else {
            return Parse.history.navigate("account/setup", true);
          }
        });
        this.listenTo(Parse.Dispatcher, "user:logout", function() {
          return Parse.history.loadUrl(location.pathname);
        });
        this.listenTo(Parse.history, "route", function(router, route, params) {
          return Parse.App.search.$('input').val("").blur();
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
        if (Parse.User.current()) {
          return require(["views/activity/index"], function(ActivityIndexView) {
            if (!view || !(view instanceof ActivityIndexView)) {
              _this.view = new ActivityIndexView({
                params: {}
              }).render();
              if (view) {
                return view.clear();
              }
            }
          });
        } else {
          return require(["views/home/anon"], function(AnonHomeView) {
            if (!view || !(view instanceof AnonHomeView)) {
              _this.view = new AnonHomeView({
                params: {}
              }).render();
              if (view) {
                return view.clear();
              }
            }
          });
        }
      };

      DesktopRouter.prototype.outside = function(splat) {
        var view,
          _this = this;

        view = this.view;
        return require(["views/activity/index"], function(ActivityIndexView) {
          var vars;

          if (!view || !(view instanceof ActivityIndexView)) {
            vars = _this.deparamAction(splat);
            _this.view = new ActivityIndexView({
              location: vars.path,
              params: vars.params
            }).render();
            if (view) {
              return view.clear();
            }
          }
        });
      };

      DesktopRouter.prototype.activityShow = function(id) {
        var view,
          _this = this;

        view = this.view;
        return require(["collections/ActivityList", "views/activity/Show"], function(ActivityList, ShowActivityView) {
          var model;

          if (!view || !(view instanceof ShowActivityView) || id !== view.model.id) {
            Parse.App.activity = Parse.App.activity || new ActivityList([], {});
            model = Parse.App.activity.get(id);
            if (model) {
              _this.view = new ShowActivityView({
                model: model
              }).render();
              if (view) {
                return view.clear();
              }
            } else {
              return new Parse.Query("Activity").get(id, {
                success: function(model) {
                  Parse.App.activity.add(model);
                  _this.view = new ShowActivityView({
                    model: model
                  }).render();
                  if (view) {
                    return view.clear();
                  }
                },
                error: function(object, error) {
                  return _this.accessDenied();
                }
              });
            }
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
          _this.view.render();
          if (view) {
            return view.clear();
          }
        });
      };

      DesktopRouter.prototype.insideManage = function(splat) {
        var view,
          _this = this;

        view = this.view;
        if (Parse.User.current()) {
          if (Parse.User.current().get("network")) {
            return require(["views/network/Manage"], function(NetworkView) {
              var vars;

              vars = _this.deparamAction(splat);
              if (!view || !(view instanceof NetworkView)) {
                vars.model = Parse.User.current().get("network");
                _this.view = new NetworkView(vars);
                if (view) {
                  return view.clear();
                }
              } else {
                return view.changeSubView(vars.path, vars.params);
              }
            });
          } else if (Parse.User.current().get("property")) {
            if (Parse.User.current().get("property").mgr === void 0) {
              if (Parse.User.current().get("property").get("mgrRole")) {
                return Parse.User.current().get("property").get("mgrRole").getUsers().query().get(Parse.User.current().id, {
                  success: function(user) {
                    if (user) {
                      Parse.User.current().get("property").mgr = true;
                      return _this.propertiesManage(Parse.User.current().get("property").id, splat);
                    } else {
                      Parse.User.current().get("property").mgr = false;
                      return require(["views/lease/Manage"], function(LeaseView) {
                        var vars;

                        vars = _this.deparamAction(splat);
                        if (!view || !(view instanceof LeaseView)) {
                          vars.model = Parse.User.current().get("lease");
                          _this.view = new LeaseView(vars);
                          if (view) {
                            return view.clear();
                          }
                        } else {
                          return view.changeSubView(vars.path, vars.params);
                        }
                      });
                    }
                  },
                  error: function() {
                    Parse.User.current().get("property").mgr = false;
                    return _this.insideManage(splat);
                  }
                });
              } else {
                Parse.User.current().get("property").mgr = false;
                return this.insideManage(splat);
              }
            } else {
              if (Parse.User.current().get("property").mgr) {
                return this.propertiesManage(Parse.User.current().get("property").id, splat);
              } else {
                return require(["views/lease/Manage"], function(LeaseView) {
                  var vars;

                  vars = _this.deparamAction(splat);
                  if (!view || !(view instanceof LeaseView)) {
                    vars.model = Parse.User.current().get("lease");
                    _this.view = new LeaseView(vars);
                    if (view) {
                      return view.clear();
                    }
                  } else {
                    return view.changeSubView(vars.path, vars.params);
                  }
                });
              }
            }
          } else {
            return Parse.history.navigate("account/setup", true);
          }
        } else {
          return Parse.history.navigate("account/login", true);
        }
      };

      DesktopRouter.prototype.movein = function() {
        var view,
          _this = this;

        view = this.view;
        return require(["views/property/new/Wizard"], function(PropertyWizard) {
          if (!view || !(view instanceof PropertyWizard)) {
            _this.view = new PropertyWizard({
              forNetwork: false
            });
            _this.view.setElement("#main");
            _this.view.render();
            if (view) {
              return view.clear();
            }
          }
        });
      };

      DesktopRouter.prototype.propertiesNew = function() {
        var view,
          _this = this;

        view = this.view;
        return require(["views/property/new/Wizard"], function(PropertyWizard) {
          if (!view || !(view instanceof PropertyWizard)) {
            _this.view = new PropertyWizard({
              forNetwork: true
            });
            _this.view.setElement("#main");
            _this.view.render();
            if (view) {
              return view.clear();
            }
          }
        });
      };

      DesktopRouter.prototype.propertiesManage = function(id, splat) {
        var vars, view,
          _this = this;

        if (Parse.User.current()) {
          view = this.view;
          vars = this.deparamAction(splat);
          if (Parse.User.current().get("network") || Parse.User.current().get("property")) {
            return require(["views/property/Manage"], function(ManagePropertyView) {
              var model;

              if (!view || !(view instanceof ManagePropertyView) || id !== view.model.id) {
                model = Parse.User.current().get("network") ? Parse.User.current().get("network").properties.get(id) : Parse.User.current().get("property");
                if (model) {
                  vars.model = model;
                  _this.view = new ManagePropertyView(vars);
                  if (view) {
                    return view.clear();
                  }
                } else {
                  return new Parse.Query("Property").get(id, {
                    success: function(model) {
                      Parse.User.current().get("network").properties.add(model);
                      vars.model = model;
                      _this.view = new ManagePropertyView(vars);
                      if (view) {
                        return view.clear();
                      }
                    },
                    error: function(object, error) {
                      return _this.accessDenied();
                    }
                  });
                }
              } else {
                return view.changeSubView(vars.path, vars.params);
              }
            });
          } else {
            return Parse.history.navigate("account/setup", true);
          }
        } else {
          return this.signupOrLogin();
        }
      };

      DesktopRouter.prototype.propertiesPublic = function(country, region, city, id, slug) {
        var place, view,
          _this = this;

        view = this.view;
        place = "" + city + "--" + region + "--" + country;
        return require(["models/Property", "views/property/Public"], function(Property, PublicPropertyView) {
          var model;

          if (Parse.User.current()) {
            if (Parse.User.current().get("property") && id === Parse.User.current().get("property").id) {
              console.log(Parse.User.current().get("property"));
              _this.view = new PublicPropertyView({
                params: {},
                model: Parse.User.current().get("property"),
                place: place
              }).render();
              if (view) {
                return view.clear();
              }
            } else if (Parse.User.current().get("network") && Parse.User.current().get("network").properties.find(function(p) {
              return p.id === id;
            })) {
              model = Parse.User.current().get("network").properties.find(function(p) {
                return p.id === id;
              });
              console.log(model);
              _this.view = new PublicPropertyView({
                params: {},
                model: model,
                place: place
              }).render();
              if (view) {
                return view.clear();
              }
            } else {
              return new Parse.Query(Property).get(id, {
                success: function(model) {
                  _this.view = new PublicPropertyView({
                    params: {},
                    model: model,
                    place: place
                  }).render();
                  if (view) {
                    return view.clear();
                  }
                },
                error: function(object, error) {
                  return _this.accessDenied();
                }
              });
            }
          } else {
            return new Parse.Query(Property).get(id, {
              success: function(model) {
                _this.view = new PublicPropertyView({
                  params: {},
                  model: model,
                  place: place
                }).render();
                if (view) {
                  return view.clear();
                }
              },
              error: function(object, error) {
                return _this.accessDenied();
              }
            });
          }
        });
      };

      DesktopRouter.prototype.listingsNew = function() {
        var view,
          _this = this;

        view = this.view;
        return require(["views/listing/new"], function(NewListingView) {
          if (!view || !(view instanceof NewListingView)) {
            _this.view = new NewListingView({
              forNetwork: true,
              baseUrl: "/inside/listings"
            });
            _this.view.setElement("#main");
            _this.view.render();
            if (view) {
              return view.clear();
            }
          }
        });
      };

      DesktopRouter.prototype.leasesNew = function() {
        var view,
          _this = this;

        view = this.view;
        return require(["views/lease/new"], function(NewLeaseView) {
          if (!view || !(view instanceof NewLeaseView)) {
            _this.view = new NewLeaseView({
              forNetwork: true,
              baseUrl: "/inside/tenants"
            });
            _this.view.setElement("#main");
            _this.view.render();
            if (view) {
              return view.clear();
            }
          }
        });
      };

      DesktopRouter.prototype.tenantsNew = function() {
        var view,
          _this = this;

        view = this.view;
        return require(["views/tenant/new"], function(NewTenantView) {
          if (!view || !(view instanceof NewTenantView)) {
            _this.view = new NewTenantView({
              forNetwork: true,
              baseUrl: "/inside/tenants"
            });
            _this.view.setElement("#main");
            _this.view.render();
            if (view) {
              return view.clear();
            }
          }
        });
      };

      DesktopRouter.prototype.profileShow = function(id, splat) {
        var view,
          _this = this;

        view = this.view;
        return require(["models/Profile", "views/profile/Show"], function(Profile, ShowProfileView) {
          var vars;

          vars = _this.deparamAction(splat);
          if (!view || !(view instanceof ShowProfileView) || id !== view.model.id) {
            if (!id && Parse.User.current()) {
              id = Parse.User.current().get("profile").id;
            }
            if (Parse.User.current() && Parse.User.current().get("profile") && id === Parse.User.current().get("profile").id) {
              _this.view = new ShowProfileView({
                path: vars.path,
                params: vars.params,
                model: Parse.User.current().get("profile"),
                current: true
              });
              if (view) {
                return view.clear();
              }
            } else {
              return (new Parse.Query(Profile)).get(id, {
                success: function(obj) {
                  _this.view = new ShowProfileView({
                    path: vars.path,
                    params: vars.params,
                    model: obj,
                    current: false
                  });
                  if (view) {
                    return view.clear();
                  }
                }
              });
            }
          } else {
            return view.changeSubView(vars.path, vars.params);
          }
        });
      };

      DesktopRouter.prototype.accountSetup = function() {
        var view,
          _this = this;

        view = this.view;
        if (Parse.User.current()) {
          return require(["views/user/Setup"], function(UserSetupView) {
            _this.view = new UserSetupView().render();
            if (view) {
              return view.clear();
            }
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
            _this.view = new EditProfileView({
              model: Parse.User.current().get("profile"),
              current: true
            }).render();
            if (view) {
              return view.clear();
            }
          });
        } else {
          return require(["views/user/Account"], function(UserAccountView) {
            var vars;

            vars = _this.deparamAction(splat);
            if (!view || !(view instanceof UserAccountView)) {
              _this.view = new UserAccountView(vars);
              if (view) {
                return view.clear();
              }
            } else {
              return view.changeSubView(vars.path, vars.params);
            }
          });
        }
      };

      DesktopRouter.prototype.notifications = function() {
        var view,
          _this = this;

        view = this.view;
        if (Parse.User.current()) {
          return require(["views/notification/All"], function(AllNotificationsView) {
            _this.view = new AllNotificationsView().render();
            if (view) {
              return view.clear();
            }
          });
        } else {
          return this.signupOrLogin();
        }
      };

      DesktopRouter.prototype.signup = function() {
        var view,
          _this = this;

        view = this.view;
        if (!Parse.User.current()) {
          return require(["views/user/Signup"], function(SignupView) {
            _this.view = new SignupView().render();
            if (view) {
              return view.clear();
            }
          });
        } else {
          Parse.history.navigate("users/" + (Parse.User.current().get("profile").id));
          return this.profileShow();
        }
      };

      DesktopRouter.prototype.login = function() {
        var view,
          _this = this;

        view = this.view;
        if (!Parse.User.current()) {
          return require(["views/user/Login"], function(LoginView) {
            _this.view = new LoginView().render();
            if (view) {
              return view.clear();
            }
          });
        } else {
          Parse.history.navigate("users/" + (Parse.User.current().get("profile").id));
          return this.profileShow();
        }
      };

      DesktopRouter.prototype.resetPassword = function() {
        var view,
          _this = this;

        view = this.view;
        return require(["views/user/Reset"], function(ResetView) {
          _this.view = new ResetView().render();
          if (view) {
            return view.clear();
          }
        });
      };

      DesktopRouter.prototype.logout = function() {
        var view;

        view = this.view;
        if (Parse.User.current()) {
          Parse.User.logOut();
          Parse.Dispatcher.trigger("user:change");
          Parse.Dispatcher.trigger("user:logout");
          return Parse.history.navigate("", true);
        } else {
          return Parse.history.navigate("account/login", true);
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
                      type: 'danger',
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
                type: 'danger',
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

      DesktopRouter.prototype.fourOhFour = function() {
        return require(["views/helper/Alert", 'i18n!nls/common'], function(Alert, i18nCommon) {
          new Alert({
            event: 'access-denied',
            type: 'danger',
            fade: true,
            heading: i18nCommon.errors.fourOhFour,
            message: i18nCommon.errors.not_found
          });
          return Parse.history.navigate("", true);
        });
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
          return new Alert({
            event: 'access-denied',
            type: 'danger',
            fade: true,
            heading: i18nCommon.errors.access_denied,
            message: i18nCommon.errors.no_permission
          });
        });
      };

      DesktopRouter.prototype.signupOrLogin = function() {
        return $("#login-modal").modal();
      };

      return DesktopRouter;

    })(Parse.Router);
  });

}).call(this);
