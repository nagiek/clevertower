(function() {

  require.config({
    baseUrl: "/js",
    paths: {
      jquery: '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min',
      jqueryuiwidget: 'libs/jqueryui/jquery.ui.widget.min',
      underscore: '//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min',
      backbone: "//www.parsecdn.com/js/parse-1.2.2",
      jquerymobile: '//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min',
      datepicker: 'libs/bootstrap/bootstrap-datepicker.min',
      serializeObject: "app/plugins/serialize_object",
      filePicker: "app/plugins/file_picker",
      "jquery.fileupload-pr": 'app/plugins/jquery-fileupload-pr',
      "jquery.fileupload-ui": 'app/plugins/jquery-fileupload-ui',
      "jquery.fileupload-fp": 'app/plugins/jquery-fileupload-fp',
      "jquery.fileupload": "app/plugins/jquery-fileupload",
      'load-image': '//blueimp.github.com/JavaScript-Load-Image/load-image.min',
      'canvas-to-blob': '//blueimp.github.com/JavaScript-Canvas-to-Blob/canvas-to-blob.min',
      "underscore.email": "app/plugins/underscore-email",
      "underscore.inflection": "app/plugins/underscore-inflection",
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
      underscore: {
        exports: '_'
      }
    }
  });

  define("gmaps", ["async!//maps.googleapis.com/maps/api/js?v=3&sensor=false&key=AIzaSyD_xrni-sLyPudfQ--6gn7yAhaW6nTuqkg"], function() {
    return window.google.maps;
  });

  require(["jquery", "backbone", "routers/Desktop", "json2", "bootstrap", "serializeObject"], function($, Parse, AppRouter) {
    Parse.initialize("z00OPdGYL7X4uW9soymp8n5JGBSE6k26ILN1j3Hu", "NifB9pRHfmsTDQSDA9DKxMuux03S4w2WGVdcxPHm");
    Parse.User.prototype.defaults = {
      first_name: "",
      last_name: "",
      image_thumb: "",
      image_profile: "",
      image_full: ""
    };
    Parse.User.prototype.cover = function(format) {
      var img;
      img = this.get("image_" + format);
      if (img === '') {
        img = "/img/fallback/avatar-" + format + ".png";
      }
      return img;
    };
    Parse.User.prototype.validate = function(attrs, options) {
      if (_.has(attrs, "ACL") && !(attrs.ACL instanceof Parse.ACL)) {
        return new Parse.Error(Parse.Error.OTHER_CAUSE, "ACL must be a Parse.ACL.");
      }
      if (attrs.email && attrs.email !== '') {
        if (!/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test(attrs.email)) {
          return {
            message: 'invalid_email'
          };
        }
      }
      return false;
    };
    Parse.User.prototype.validate = function(attrs, options) {
      if (attrs == null) {
        attrs = {};
      }
      if (options == null) {
        options = {};
      }
      if (_.has(attrs, "ACL") && !(attrs.ACL instanceof Parse.ACL)) {
        return new Parse.Error(Parse.Error.OTHER_CAUSE, "ACL must be a Parse.ACL.");
      }
      if (attrs.email && attrs.email !== '') {
        if (!/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test(attrs.email)) {
          return {
            message: 'invalid_email'
          };
        }
      }
      return false;
    };
    return new AppRouter();
  });

}).call(this);
