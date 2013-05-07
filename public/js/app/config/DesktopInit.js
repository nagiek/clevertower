(function() {
  var onNetwork, router;

  require.config({
    baseUrl: "/js",
    paths: {
      jquery: "//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min",
      jqueryui: "libs/jqueryui/jquery-ui-1.10.3.custom.min",
      underscore: "//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min",
      backbone: "//www.parsecdn.com/js/parse-1.2.7",
      facebook: "//connect.facebook.net/en_US/all",
      jqueryuiwidget: "libs/jqueryui/jquery.ui.widget.min",
      jquerymobile: "//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min",
      datepicker: "libs/bootstrap/bootstrap-datepicker.min",
      serializeObject: "app/plugins/serialize_object",
      filePicker: "app/plugins/file_picker",
      toggler: "app/plugins/toggler",
      masonry: "libs/jquery/jquery.masonry",
      rangeSlider: "libs/jquery/jquery.rangeSlider",
      rangeSliderHandle: "libs/jquery/jquery.rangeSliderHandle",
      rangeSliderDraggable: "libs/jquery/jquery.rangeSliderDraggable",
      "jquery.fileupload-pr": "app/plugins/jquery-fileupload-pr",
      "jquery.fileupload-ui": "app/plugins/jquery-fileupload-ui",
      "jquery.fileupload-fp": "app/plugins/jquery-fileupload-fp",
      "jquery.fileupload": "app/plugins/jquery-fileupload",
      "load-image": "//blueimp.github.com/JavaScript-Load-Image/load-image.min",
      "canvas-to-blob": "//blueimp.github.com/JavaScript-Canvas-to-Blob/canvas-to-blob.min",
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

  window.GMAPS_KEY = "AIzaSyDX4LWzK2LTiw4EJFKlOHwBK3m7AmIdpgE";

  window.APPID = "z00OPdGYL7X4uW9soymp8n5JGBSE6k26ILN1j3Hu";

  window.JSKEY = "NifB9pRHfmsTDQSDA9DKxMuux03S4w2WGVdcxPHm";

  window.RESTAPIKEY = "NZDSkpVLG9Gw6NiZOUBevvLt4qPGtpCsLvWh4ZDc";

  define("gmaps", ["async!//maps.googleapis.com/maps/api/js?v=3.11&libraries=places&sensor=false&key=" + window.GMAPS_KEY], function() {
    return window.google.maps;
  });

  onNetwork = window.location.host.split(".").length > 2;

  router = onNetwork ? "routers/Network" : "routers/Desktop";

  require(["jquery", "underscore", "backbone", "facebook", "models/Profile", router, "underscore.string", "json2", "bootstrap", "serializeObject", "typeahead", "masonry"], function($, _, Parse, FB, Profile, AppRouter, _String) {
    var listenEvents, listenMethods;
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
    _.extend(Parse.View.prototype, listenEvents);
    _.extend(Parse.Object.prototype, listenEvents);
    Parse.View.prototype.remove = function() {
      this.$el.remove();
      this.stopListening();
      return this;
    };
    Parse.initialize(window.APPID, window.JSKEY);
    Parse.App = {};
    _.str = _String;
    $.ajaxSetup({
      beforeSend: function(jqXhr, settings) {
        jqXhr.setRequestHeader("X-Parse-Application-Id", window.APPID);
        return jqXhr.setRequestHeader("X-Parse-REST-API-Key", window.RESTAPIKEY);
      }
    });
    Parse.onNetwork = onNetwork;
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
      var networkPromise, profilePromise,
        _this = this;
      profilePromise = (new Parse.Query(Profile)).equalTo("user", this).first();
      networkPromise = (new Parse.Query("_User")).include('network.role').equalTo("objectId", this.id).first();
      return Parse.Promise.when(profilePromise, networkPromise).then(function(profile, user) {
        var network;
        profile.prep("applicants").fetch();
        _this.profile = profile;
        if (user) {
          network = user.get("network");
        }
        if (user && network) {
          network.prep("properties").fetch();
          network.prep("managers").fetch();
          network.prep("tenants").fetch();
          network.prep("listings").fetch();
          network.prep("applicants").fetch();
          network.prep("inquiries").fetch();
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
