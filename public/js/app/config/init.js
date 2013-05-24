(function() {
  (function(ua, w, d, undefined_) {
    var config, production;

    production = false;
    config = {};
    return w.addEventListener("DOMContentLoaded", (function() {
      var loadCSS, loadFiles, loadJS;

      loadCSS = function(urls, callback) {
        var link, x;

        x = void 0;
        link = void 0;
        x = 0;
        while (x <= urls.length - 1) {
          link = d.createElement("link");
          link.type = "text/css";
          link.rel = "stylesheet";
          link.href = urls[x];
          d.querySelector("head").appendChild(link);
          x += 1;
        }
        if (callback) {
          return callback();
        }
      };
      loadJS = function(files, callback) {
        var file, script, x;

        x = void 0;
        script = void 0;
        file = void 0;
        x = 0;
        while (x <= files.length - 1) {
          file = files[x];
          script = d.createElement("script");
          if (((typeof file).toLowerCase()) === "object" && file["data-main"] !== undefined) {
            script.setAttribute("data-main", file["data-main"]);
            script.src = file.src;
          } else {
            script.src = file;
          }
          d.body.appendChild(script);
          x += 1;
        }
        if (callback) {
          return callback();
        }
      };
      loadFiles = function(obj, callback) {
        if (production) {
          return loadCSS(obj["prod-css"], function() {
            if (obj["prod-js"]) {
              return loadJS(obj["prod-js"], callback);
            }
          });
        } else {
          return loadCSS(obj["dev-css"], function() {
            if (obj["dev-js"]) {
              return loadJS(obj["dev-js"], callback);
            }
          });
        }
      };
      if (/iPhone|iPod|iPad|Android|BlackBerry|Opera Mini|IEMobile/.test(ua)) {
        config = {
          "dev-css": ["/css/libs/jquery.mobile.css"],
          "prod-css": ["/css/libs/jquery.mobile.min.css"],
          "dev-js": [
            {
              "data-main": "/js/app/config/MobileInit.js",
              src: "/js/libs/require/require.js"
            }
          ],
          "prod-js": ["/js/app/config/MobileInit.min.js"]
        };
      } else {
        config = {
          "dev-css": [],
          "prod-css": [],
          "dev-js": [
            {
              "data-main": "/js/app/config/DesktopInit.js",
              src: "/js/libs/require/require.js"
            }
          ],
          "prod-js": ["/js/app/config/DesktopInit.min.js"]
        };
      }
      return loadFiles(config, function() {
        return loadFiles({
          "dev-css": ["/css/app/cali.css"],
          "prod-css": ["/css/app/cali.min.css"]
        });
      });
    }), false);
  })(navigator.userAgent || navigator.vendor || window.opera, window, window.document);

}).call(this);
