(function() {
  var onNetwork, router;

  require.config({
    baseUrl: "/js",
    paths: {
      jquery: "//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min",
      jqueryui: "libs/jqueryui/jquery-ui-1.10.3.custom.min",
      underscore: "//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min",
      backbone: "//www.parsecdn.com/js/parse-1.2.8",
      facebook: "//connect.facebook.net/en_US/all",
      jqueryuiwidget: "libs/jqueryui/jquery.ui.widget.min",
      jquerymobile: "//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min",
      datepicker: "libs/bootstrap/bootstrap-datepicker.min",
      serializeObject: "app/plugins/serialize_object",
      filePicker: "app/plugins/file_picker",
      masonry: "libs/jquery/jquery.masonry",
      rangeSlider: "libs/jquery/jquery.rangeSlider",
      slideshowify: "libs/jquery/jquery.slideshowify",
      "jquery.fileupload-pr": "app/plugins/jquery-fileupload-pr",
      "jquery.fileupload-ui": "app/plugins/jquery-fileupload-ui",
      "jquery.fileupload-fp": "app/plugins/jquery-fileupload-fp",
      "jquery.fileupload": "app/plugins/jquery-fileupload",
      "load-image": "libs/plugins/load-image",
      "canvas-to-blob": "libs/plugins/canvas-to-blob",
      "underscore.email": "app/plugins/underscore-email",
      "underscore.inflection": "app/plugins/underscore-inflection",
      "underscore.string": "//cdnjs.cloudflare.com/ajax/libs/underscore.string/2.3.0/underscore.string.min",
      typeahead: "libs/typeahead.js/typeahead-computed",
      pusher: "//d3dy5gmtp8yhk7.cloudfront.net/2.0/pusher.min",
      moment: "//cdnjs.cloudflare.com/ajax/libs/moment.js/2.0.0/moment.min",
      bootstrap: "libs/bootstrap/bootstrap",
      json2: "//cdnjs.cloudflare.com/ajax/libs/json2/20121008/json2",
      text: "libs/plugins/text",
      async: "libs/plugins/async",
      goog: "libs/plugins/goog",
      propertyParser: "libs/plugins/propertyParser",
      i18n: "libs/plugins/i18n",
      collections: "app/collections",
      models: "app/models",
      nls: "app/nls",
      plugins: "app/plugins",
      routers: "app/routers",
      templates: "app/templates",
      views: "app/views"
    },
    shim: {
      bootstrap: ["jquery"],
      jqueryui: ["jquery"],
      jqueryuiwidget: ["jquery"],
      jquerymobile: ["jquery"],
      typeahead: ["jquery"],
      backbone: {
        deps: ["underscore", "jquery"],
        exports: "Parse"
      },
      pusher: {
        exports: "Pusher"
      },
      underscore: {
        exports: "_"
      }
    }
  });

  window.GCLIENT_ID = "318583282454-5r9n44vinmdfg9eakbbgnoa1iddk0f27.apps.googleusercontent.com";

  window.GAPI_KEY = "AIzaSyDX4LWzK2LTiw4EJFKlOHwBK3m7AmIdpgE";

  window.APPID = "z00OPdGYL7X4uW9soymp8n5JGBSE6k26ILN1j3Hu";

  window.JSKEY = "NifB9pRHfmsTDQSDA9DKxMuux03S4w2WGVdcxPHm";

  window.RESTAPIKEY = "NZDSkpVLG9Gw6NiZOUBevvLt4qPGtpCsLvWh4ZDc";

  define("gapi", ["async!//apis.google.com/js/client.js?onload="], function() {
    window.gapi.client.setApiKey(window.GAPI_KEY);
    return window.gapi;
  });

  define("gmaps", ["async!//maps.googleapis.com/maps/api/js?v=3.11&libraries=places&sensor=false&key=" + window.GAPI_KEY], function() {
    return window.google.maps;
  });

  onNetwork = window.location.host.split(".").length > 2;

  router = onNetwork ? "routers/Network" : "routers/Desktop";

  require(["jquery", "underscore", "backbone", "facebook", "models/Property", "models/Unit", "models/Lease", "models/Profile", "collections/ListingFeaturedList", "collections/ActivityList", "collections/NotificationList", router, "underscore.string", "json2", "bootstrap", "serializeObject", "typeahead", "masonry"], function($, _, Parse, FB, Property, Unit, Lease, Profile, FeaturedListingList, ActivityList, NotificationList, AppRouter, _String) {
    var eventSplitter, eventsApi, listenEvents, listenMethods;

    eventSplitter = /\s+/;
    eventsApi = function(obj, action, name, rest) {
      var i, key, l, names;

      if (!name) {
        return true;
      }
      if (typeof name === "object") {
        for (key in name) {
          obj[action].apply(obj, [key, name[key]].concat(rest));
        }
        return false;
      }
      if (eventSplitter.test(name)) {
        names = name.split(eventSplitter);
        i = 0;
        l = names.length;
        while (i < l) {
          obj[action].apply(obj, [names[i]].concat(rest));
          i++;
        }
        return false;
      }
      return true;
    };
    Parse.Events.once = function(name, callback, context) {
      var once, self;

      if (!eventsApi(this, "once", name, [callback, context]) || !callback) {
        return this;
      }
      self = this;
      once = _.once(function() {
        self.off(name, once);
        return callback.apply(this, arguments);
      });
      once._callback = callback;
      return this.on(name, once, context);
    };
    Parse.Object.prototype.once = Parse.Events.once;
    Parse.View.prototype.once = Parse.Events.once;
    Parse.Collection.prototype.once = Parse.Events.once;
    listenMethods = {
      listenTo: "on",
      listenToOnce: "once"
    };
    listenEvents = {};
    _.each(listenMethods, function(implementation, method) {
      return listenEvents[method] = function(obj, name, callback) {
        var id, listeners;

        listeners = this._listeners || (this._listeners = {});
        id = obj._listenerId || (obj._listenerId = _.uniqueId("l"));
        listeners[id] = obj;
        if (typeof name === "object") {
          callback = this;
        }
        obj[implementation](name, callback, this);
        return this;
      };
    });
    listenEvents.stopListening = function(obj, name, callback) {
      var deleteListener, id, listeners;

      listeners = this._listeners;
      if (!listeners) {
        return this;
      }
      deleteListener = !name && !callback;
      if (typeof name === "object") {
        callback = this;
      }
      if (obj) {
        (listeners = {})[obj._listenerId] = obj;
      }
      for (id in listeners) {
        listeners[id].off(name, callback, this);
        if (deleteListener) {
          delete this._listeners[id];
        }
      }
      return this;
    };
    _.extend(Parse.Router.prototype, listenEvents);
    _.extend(Parse.View.prototype, listenEvents);
    _.extend(Parse.Object.prototype, listenEvents);
    Parse.View.prototype.remove = function() {
      this.$el.remove();
      this.stopListening();
      return this;
    };
    Parse.initialize(window.APPID, window.JSKEY);
    Parse.onNetwork = onNetwork;
    Parse.App = {};
    Parse.App.featuredListings = new FeaturedListingList;
    Parse.App.countryCodes = {
      CA: "Canada",
      US: "United States"
    };
    _.str = _String;
    $.ajaxSetup({
      beforeSend: function(jqXHR, settings) {
        jqXHR.setRequestHeader("X-Parse-Application-Id", window.APPID);
        return jqXHR.setRequestHeader("X-Parse-REST-API-Key", window.RESTAPIKEY);
      }
    });
    Parse.FacebookUtils.init({
      appId: '387187337995318',
      channelUrl: '//clevertower.dev:3000/fb-channel',
      cookie: true,
      xfbml: true
    });
    Parse.Collection.prototype.where = function(attrs, first) {
      if (_.isEmpty(attrs)) {
        if (first) {
          return void 0;
        } else {
          return [];
        }
      }
      return this[first ? 'find' : 'filter'](function(model) {
        var key, _i, _len;

        for (_i = 0, _len = attrs.length; _i < _len; _i++) {
          key = attrs[_i];
          if (attrs[key] !== model.get(key)) {
            return false;
          }
        }
        return true;
      });
    };
    Parse.Collection.prototype.findWhere = function(attrs) {
      return this.where(attrs, true);
    };
    Parse.User.prototype.defaults = {
      privacy_visible: false,
      privacy_unit: false,
      type: "tenant"
    };
    Parse.User.prototype.validate = function(attrs, options) {
      if (_.has(attrs, "ACL") && !(attrs.ACL instanceof Parse.ACL)) {
        return new Parse.Error(Parse.Error.OTHER_CAUSE, "ACL must be a Parse.ACL.");
      }
      if (attrs.email && attrs.email !== "") {
        if (!/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test(attrs.email)) {
          return {
            message: "invalid_email"
          };
        }
      }
      return false;
    };
    Parse.User.prototype.setup = function() {
      var userPromise,
        _this = this;

      userPromise = (new Parse.Query("_User")).include('lease').include('unit').include('profile').include('property.role').include('property.mgrRole').include('network.role').equalTo("objectId", this.id).first();
      this.notifications = new NotificationList;
      return Parse.Promise.when(userPromise, this.notifications.query.find()).then(function(user, notifs) {
        var network, profile;

        _this.notifications.add(notifs);
        profile = user.get("profile");
        profile.likes = new ActivityList([], {});
        profile.likes.query = profile.relation("likes").query();
        _this.set("profile", profile);
        _this.set("lease", user.get("lease"));
        if (user.get("unit")) {
          _this.set("unit", new Unit(user.get("unit").attributes));
        }
        _this.set("property", user.get("property"));
        network = user.get("network");
        if (network) {
          return _this.networkSetup(network);
        }
      });
    };
    Parse.User.prototype.networkSetup = function(network) {
      var role,
        _this = this;

      network.prep("properties").fetch();
      network.prep("units").fetch();
      network.prep("activity").fetch();
      network.prep("managers").fetch();
      network.prep("tenants").fetch();
      network.prep("listings").fetch();
      network.prep("applicants").fetch();
      network.prep("inquiries").fetch();
      role = network.get("role");
      return role.getUsers().query().get(Parse.User.current().id, {
        success: function(user) {
          network.mgr = true;
          return _this.set("network", network);
        },
        error: function() {
          network.mgr = false;
          return _this.set("network", network);
        }
      });
    };
    Parse.Dispatcher = {};
    _.extend(Parse.Dispatcher, Parse.Events);
    if (Parse.User.current()) {
      return Parse.User.current().setup().then(function() {
        return new AppRouter();
      });
    } else {
      return new AppRouter();
    }
  });

}).call(this);
