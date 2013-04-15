(function() {
  var onNetwork, router;

  require.config({
    baseUrl: "/js",
    paths: {
      jquery: "//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min",
      underscore: "//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min",
      backbone: "//www.parsecdn.com/js/parse-1.2.2",
      facebook: "//connect.facebook.net/en_US/all",
      jqueryuiwidget: "libs/jqueryui/jquery.ui.widget.min",
      jquerymobile: "//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min",
      datepicker: "libs/bootstrap/bootstrap-datepicker.min",
      serializeObject: "app/plugins/serialize_object",
      filePicker: "app/plugins/file_picker",
      toggler: "app/plugins/toggler",
      "jquery.fileupload-pr": "app/plugins/jquery-fileupload-pr",
      "jquery.fileupload-ui": "app/plugins/jquery-fileupload-ui",
      "jquery.fileupload-fp": "app/plugins/jquery-fileupload-fp",
      "jquery.fileupload": "app/plugins/jquery-fileupload",
      "load-image": "//blueimp.github.com/JavaScript-Load-Image/load-image.min",
      "canvas-to-blob": "//blueimp.github.com/JavaScript-Canvas-to-Blob/canvas-to-blob.min",
      "underscore.email": "app/plugins/underscore-email",
      "underscore.inflection": "app/plugins/underscore-inflection",
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

  define("gmaps", ["async!//maps.googleapis.com/maps/api/js?v=3&sensor=false&key=AIzaSyD_xrni-sLyPudfQ--6gn7yAhaW6nTuqkg"], function() {
    return window.google.maps;
  });

  onNetwork = window.location.host.split(".").length > 2;

  router = onNetwork ? "routers/Network" : "routers/Desktop";

  require(["jquery", "backbone", "facebook", "collections/property/PropertyList", "models/Profile", router, "json2", "bootstrap", "serializeObject"], function($, Parse, FB, PropertyList, Profile, AppRouter) {
    var networkPromise, profilePromise,
      _this = this;
    Parse.initialize("z00OPdGYL7X4uW9soymp8n5JGBSE6k26ILN1j3Hu", "NifB9pRHfmsTDQSDA9DKxMuux03S4w2WGVdcxPHm");
    Parse.FacebookUtils.init({
      appId: '387187337995318',
      channelUrl: '//localhost:3000/fb-channel',
      status: true,
      cookie: true,
      xfbml: true
    });
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
    Parse.Dispatcher = {};
    _.extend(Parse.Dispatcher, Parse.Events);
    if (Parse.User.current()) {
      profilePromise = (new Parse.Query(Profile)).equalTo("user", Parse.User.current()).first();
      networkPromise = (new Parse.Query("_User")).include('network.role').equalTo("objectId", Parse.User.current().id).first();
      return Parse.Promise.when(profilePromise, networkPromise).then(function(profile, user) {
        var network;
        Parse.User.current().profile = profile;
        network = user.get("network");
        if (onNetwork) {
          network.prep("properties");
          network.prep("managers");
        }
        Parse.User.current().set("network", network);
        return new AppRouter();
      });
    } else {
      return new AppRouter();
    }
  });

}).call(this);
