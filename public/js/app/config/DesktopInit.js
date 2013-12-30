(function() {
  require.config({
    baseUrl: "/js",
    paths: {
      jquery: "//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min",
      jqueryui: "libs/jqueryui/jquery-ui-1.10.3.custom.min",
      underscore: "//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min",
      backbone: "libs/parse/parse-1.2.11",
      facebook: "//connect.facebook.net/en_US/all",
      jqueryuiwidget: "libs/jqueryui/jquery.ui.widget.min",
      jquerymobile: "//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min",
      datepicker: "libs/bootstrap/bootstrap-datepicker.min",
      serializeObject: "app/plugins/serialize_object",
      filePicker: "app/plugins/file_picker",
      masonry: "libs/jquery/jquery.masonry",
      transit: "libs/jquery/jquery.transit",
      infinity: "libs/jquery/infinity",
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
      typeahead: "libs/typeahead.js/typeahead",
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
    google.maps.visualRefresh = true;
    return window.google.maps;
  });

  require(["jquery", "underscore", "backbone", "facebook", "models/Property", "models/Unit", "models/Lease", "models/Profile", "collections/ListingFeaturedList", "collections/ActivityList", "collections/CommentList", "collections/NotificationList", "collections/ProfileList", "routers/Desktop", "underscore.string", "json2", "bootstrap", "serializeObject", "typeahead", "masonry", "transit"], function($, _, Parse, FB, Property, Unit, Lease, Profile, FeaturedListingList, ActivityList, CommentList, NotificationList, ProfileList, AppRouter, _String) {
    var addOptions, eventSplitter, eventsApi, listenEvents, listenMethods, setOptions;

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
    setOptions = {
      add: true,
      remove: true,
      merge: true
    };
    addOptions = {
      add: true,
      remove: false
    };
    Parse.Collection.prototype.countBy = function() {
      return _.countBy.apply(_, [this.models].concat(_.toArray(arguments)));
    };
    Parse.Collection.prototype.add = function(models, options) {
      return this.set(models, _.extend({
        merge: false
      }, options, addOptions));
    };
    Parse.Collection.prototype.set = function(models, options) {
      var add, at, attrs, existing, i, id, l, merge, model, modelMap, order, orderedModels, remove, singular, sort, sortAttr, sortable, targetModel, toAdd, toRemove;

      options = _.defaults({}, options, setOptions);
      if (options.parse) {
        models = this.parse(models, options);
      }
      singular = !_.isArray(models);
      models = (singular ? (models ? [models] : []) : _.clone(models));
      i = void 0;
      l = void 0;
      id = void 0;
      model = void 0;
      attrs = void 0;
      existing = void 0;
      sort = void 0;
      at = options.at;
      targetModel = this.model;
      sortable = this.comparator && (!(at != null)) && options.sort !== false;
      sortAttr = (_.isString(this.comparator) ? this.comparator : null);
      toAdd = [];
      toRemove = [];
      modelMap = {};
      add = options.add;
      merge = options.merge;
      remove = options.remove;
      order = (!sortable && add && remove ? [] : false);
      i = 0;
      l = models.length;
      while (i < l) {
        attrs = models[i];
        if (attrs instanceof Parse.Object) {
          id = model = attrs;
        } else {
          id = attrs[targetModel.prototype.idAttribute];
        }
        if (existing = this.get(id)) {
          if (remove) {
            modelMap[existing.cid] = true;
          }
          if (merge) {
            attrs = (attrs === model ? model.attributes : attrs);
            if (options.parse) {
              attrs = existing.parse(attrs, options);
            }
            existing.set(attrs, options);
            if (sortable && !sort && existing.hasChanged(sortAttr)) {
              sort = true;
            }
          }
          models[i] = existing;
        } else if (add) {
          model = models[i] = this._prepareModel(attrs, options);
          if (!model) {
            continue;
          }
          toAdd.push(model);
          model.on("all", this._onModelEvent, this);
          this._byId[model.cid] = model;
          if (model.id != null) {
            this._byId[model.id] = model;
          }
        }
        if (order) {
          order.push(existing || model);
        }
        i++;
      }
      if (remove) {
        i = 0;
        l = this.length;
        while (i < l) {
          if (!modelMap[(model = this.models[i]).cid]) {
            toRemove.push(model);
          }
          ++i;
        }
        if (toRemove.length) {
          this.remove(toRemove, options);
        }
      }
      if (toAdd.length || (order && order.length)) {
        if (sortable) {
          sort = true;
        }
        this.length += toAdd.length;
        if (at != null) {
          i = 0;
          l = toAdd.length;
          while (i < l) {
            this.models.splice(at + i, 0, toAdd[i]);
            i++;
          }
        } else {
          if (order) {
            this.models.length = 0;
          }
          orderedModels = order || toAdd;
          i = 0;
          l = orderedModels.length;
          while (i < l) {
            this.models.push(orderedModels[i]);
            i++;
          }
        }
      }
      if (sort) {
        this.sort({
          silent: true
        });
      }
      if (!options.silent) {
        i = 0;
        l = toAdd.length;
        while (i < l) {
          (model = toAdd[i]).trigger("add", model, this, options);
          i++;
        }
        if (sort || (order && order.length)) {
          this.trigger("sort", this, options);
        }
      }
      if (singular) {
        return models[0];
      } else {
        return models;
      }
    };
    Parse.initialize(window.APPID, window.JSKEY);
    Parse.App = {};
    Parse.App.featuredListings = new FeaturedListingList;
    Parse.App.activity = new ActivityList([], {});
    Parse.App.comments = new CommentList([], {});
    Parse.App.fbPerms = "email, publish_actions, user_location, user_about_me, user_birthday, user_website";
    Parse.App.countryCodes = {
      CA: "Canada",
      US: "United States"
    };
    Parse.App.cities = {
      "Montreal--QC--Canada": {
        fbID: 102184499823699,
        desc: 'Originally called Ville-Marie, or "City of Mary", it is named after Mount Royal, the triple-peaked hill located in the heart of the city.'
      },
      "Toronto--ON--Canada": {
        fbID: 110941395597405,
        desc: 'Canada’s most cosmopolitan city is situated on beautiful Lake Ontario, and is the cultural heart of south central Ontario and of English-speaking Canada.'
      }
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
      channelUrl: "//" + window.location.host + "/fb-channel",
      cookie: true,
      xfbml: false
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
      var _this = this;

      return new Parse.Query("_User").include('lease').include('unit').include('profile').include('property.profile').include('property.role').include('property.mgrRole').include('network.role').equalTo("objectId", this.id).first().then(function(user) {
        var network, profile, property;

        if (!user) {
          return;
        }
        profile = user.get("profile");
        profile.likes = new ActivityList([], {
          profile: profile
        });
        profile.likes.query = profile.relation("likes").query().include("property");
        profile.following = new ProfileList([], {});
        profile.following.query = profile.relation("following").query().include("property");
        profile.followers = new ProfileList([], {});
        profile.followers.query = profile.relation("followers").query().include("property");
        profile.followingActivity = new ActivityList([], {});
        profile.followingActivity.query.matchesQuery("profile", profile.relation("following").query());
        profile.followingActivity.query.include("property");
        profile.followingComments = new CommentList([], {});
        profile.followingComments.query.matchesQuery("profile", profile.relation("following").query());
        _this.set("profile", profile);
        if (!_this.activity) {
          _this.activity = new ActivityList([], {});
        }
        if (!_this.comments) {
          _this.comments = new CommentList([], {});
        }
        _this.set("lease", user.get("lease"));
        _this.set("unit", user.get("unit"));
        property = user.get("property");
        if (property) {
          _this.set("property", property);
          _this.propertySetup();
        }
        network = user.get("network");
        if (network) {
          _this.set("network", network);
          _this.networkSetup();
        }
        _this.notifications = new NotificationList;
        return _this.notifications.query.find({
          success: function(notifs) {
            return _this.notifications.add(notifs);
          }
        });
      });
    };
    Parse.User.prototype.propertySetup = function() {
      var property;

      property = this.get("property");
      property.prep("units").fetch();
      property.prep("activity");
      property.prep("comments");
      property.prep("managers");
      property.prep("tenants");
      property.prep("listings");
      property.prep("applicants");
      return property.prep("inquiries");
    };
    Parse.User.prototype.networkSetup = function() {
      var network, role,
        _this = this;

      network = this.get("network");
      network.prep("properties").fetch();
      network.prep("activity");
      network.prep("comments");
      network.prep("units");
      network.prep("managers");
      network.prep("tenants");
      network.prep("listings");
      network.prep("applicants");
      network.prep("inquiries");
      role = network.get("role");
      return role.getUsers().query().equalTo("objectId", Parse.User.current().id).first().then(function(user) {
        network.mgr = true;
        return _this.set("network", network, function() {
          network.mgr = false;
          return _this.set("network", network);
        });
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
