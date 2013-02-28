(function() {

  require.config({
    baseUrl: "/js",
    paths: {
      jquery: '//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min',
      jqueryui: 'libs/jqueryui/jquery-ui-1.10.1.custom.min',
      underscore: "//cdnjs.cloudflare.com/ajax/libs/lodash.js/1.0.1/lodash.min",
      backbone: "//www.parsecdn.com/js/parse-1.1.15.min",
      json2: "//cdnjs.cloudflare.com/ajax/libs/json2/20121008/json2",
      jquerymobile: '//cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.2.0/jquery.mobile.min',
      datepickermobile: 'libs/jqueryui/jquery.ui.datepicker.mobile.min',
      serializeObject: "app/plugins/serialize_object",
      bootstrap: "libs/bootstrap/bootstrap",
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
      jquerymobile: ["jquery"],
      datepickermobile: ["jquerymobile", "jqueryui"],
      backbone: {
        deps: ["underscore", "jquery"],
        exports: "Parse"
      }
    }
  });

  define("gmaps", ["async!//maps.googleapis.com/maps/api/js?v=3&sensor=false&key=AIzaSyD_xrni-sLyPudfQ--6gn7yAhaW6nTuqkg"], function() {
    return window.google.maps;
  });

  require(["jquery", "backbone", "routers/App", "json2", "jqueryui", "bootstrap", "serializeObject"], function($, Parse, AppRouter) {
    Parse.initialize("6XgIM84FecTslR8rnXBZsjnDqZgVISa946m9OmfO", "Jf4WgWUgu7R39oy5AZotay42dEDY5neMEoJddKEY");
    return new AppRouter();
  });

}).call(this);
