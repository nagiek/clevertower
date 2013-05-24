/*!
 * jQuery Transit - CSS3 transitions and transformations
 * Copyright(c) 2011 Rico Sta. Cruz <rico@ricostacruz.com>
 * MIT Licensed.
 *
 * http://ricostacruz.com/jquery.transit
 * http://github.com/rstacruz/jquery.transit
 *
 * Reviewed by Simon SER to work with jQuery 1.8.2.
 *
 */

(function (factory) {
    'use strict';
    if (typeof define === 'function' && define.amd) {
        // Register as an anonymous AMD module:
        define(['jquery'], factory);
    } else {
        // Browser globals:
        factory(window.jQuery);
    }
}(function ($) {
  "use strict";

  $.transit = {
    version: "0.1.3",

    // Map of $.css() keys to values for 'transitionProperty'.
    // See https://developer.mozilla.org/en/CSS/CSS_transitions#Properties_that_can_be_animated
    propertyMap: {
      marginLeft    : 'margin',
      marginRight   : 'margin',
      marginBottom  : 'margin',
      marginTop     : 'margin',
      paddingLeft   : 'padding',
      paddingRight  : 'padding',
      paddingBottom : 'padding',
      paddingTop    : 'padding'
    },

    // Will simply transition "instantly" if false
    enabled: true,

    // Set this to false if you don't want to use the transition end property.
    useTransitionEnd: false
  };

  var div = document.createElement('div');
  var support = {};

  // Helper function to get the proper vendor property name.
  // (`transition` => `WebkitTransition`)
  function getVendorPropertyName(prop) {
    var prefixes = ['Moz', 'Webkit', 'O', 'ms'];
    var prop_ = prop.charAt(0).toUpperCase() + prop.substr(1);

    if (prop in div.style) { return prop; }

    for (var i=0; i<prefixes.length; ++i) {
      var vendorProp = prefixes[i] + prop_;
      if (vendorProp in div.style) { return vendorProp; }
    }
  }

  // Helper function to check if transform3D is supported.
  // Should return true for Webkits and Firefox 10+.
  function checkTransform3dSupport() {
    div.style[support.transform] = '';
    div.style[support.transform] = 'rotateY(90deg)';
    return div.style[support.transform] !== '';
  }

  var isChrome = navigator.userAgent.toLowerCase().indexOf('chrome') > -1;

  // Check for the browser's transitions support.
  // You can access this in jQuery's `$.support.transition`.
  // As per [jQuery's cssHooks documentation](http://api.jquery.com/jQuery.cssHooks/),
  // we set $.support.transition to a string of the actual property name used.
  support.transition      = getVendorPropertyName('transition');
  support.transitionDelay = getVendorPropertyName('transitionDelay');
  support.transform       = getVendorPropertyName('transform');
  support.transformOrigin = getVendorPropertyName('transformOrigin');
  support.transform3d     = checkTransform3dSupport();

  $.extend($.support, support);

  var eventNames = {
    'MozTransition':    'transitionend',
    'OTransition':      'oTransitionEnd',
    'WebkitTransition': 'webkitTransitionEnd',
    'msTransition':     'MSTransitionEnd'
  };

  // Detect the 'transitionend' event needed.
  var transitionEnd = support.transitionEnd = eventNames[support.transition] || null;

  // Avoid memory leak in IE.
  div = null;

  // ## $.cssEase
  // List of easing aliases that you can use with `$.fn.transition`.
  $.cssEase = {
    '_default': 'ease',
    'in':       'ease-in',
    'out':      'ease-out',
    'in-out':   'ease-in-out',
    'snap':     'cubic-bezier(0,1,.5,1)'
  };

  // ## 'transform' CSS hook
  // Allows you to use the `transform` property in CSS.
  //
  //     $("#hello").css({ transform: "rotate(90deg)" });
  //
  //     $("#hello").css('transform');
  //     //=> { rotate: '90deg' }
  //
  $.cssHooks.transform = {
    // The getter returns a `Transform` object.
    get: function(elem) {
      return $(elem).data('transform');
    },

    // The setter accepts a `Transform` object or a string.
    set: function(elem, v) {
      var value = v;

      if (!(value instanceof Transform)) {
        value = new Transform(value);
      }

      // We've seen the 3D version of Scale() not work in Chrome when the
      // element being scaled extends outside of the viewport.  Thus, we're
      // forcing Chrome to not use the 3d transforms as well.  Not sure if
      // translate is affectede, but not risking it.  Detection code from
      // http://davidwalsh.name/detecting-google-chrome-javascript
      if (support.transform === 'WebkitTransform' && !isChrome) {
        elem.style[support.transform] = value.toString(true);
      } else {
        elem.style[support.transform] = value.toString();
      }

      $(elem).data('transform', value);
    }
  };

  // ## 'transformOrigin' CSS hook
  // Allows the use for `transformOrigin` to define where scaling and rotation
  // is pivoted.
  //
  //     $("#hello").css({ transformOrigin: '0 0' });
  //
  $.cssHooks.transformOrigin = {
    get: function(elem) {
      return elem.style[support.transformOrigin];
    },
    set: function(elem, value) {
      elem.style[support.transformOrigin] = value;
    }
  };

  // ## 'transition' CSS hook
  // Allows you to use the `transition` property in CSS.
  //
  //     $("#hello").css({ transition: 'all 0 ease 0' }); 
  //
  $.cssHooks.transition = {
    get: function(elem) {
      return elem.style[support.transition];
    },
    set: function(elem, value) {
      elem.style[support.transition] = value;
    }
  };

  // ## Other CSS hooks
  // Allows you to rotate, scale and translate.
  registerCssHook('scale');
  registerCssHook('translate');
  registerCssHook('rotate');
  registerCssHook('rotateX');
  registerCssHook('rotateY');
  registerCssHook('rotate3d');
  registerCssHook('perspective');
  registerCssHook('skewX');
  registerCssHook('skewY');
  registerCssHook('x', true);
  registerCssHook('y', true);

  // ## Transform class
  // This is the main class of a transformation property that powers
  // `$.fn.css({ transform: '...' })`.
  //
  // This is, in essence, a dictionary object with key/values as `-transform`
  // properties.
  //
  //     var t = new Transform("rotate(90) scale(4)");
  //
  //     t.rotate             //=> "90deg"
  //     t.scale              //=> "4,4"
  //
  // Setters are accounted for.
  //
  //     t.set('rotate', 4)
  //     t.rotate             //=> "4deg"
  //
  // Convert it to a CSS string using the `toString()` and `toString(true)` (for WebKit)
  // functions.
  //
  //     t.toString()         //=> "rotate(90deg) scale(4,4)"
  //     t.toString(true)     //=> "rotate(90deg) scale3d(4,4,0)" (WebKit version)
  //
  function Transform(str) {
    if (typeof str === 'string') { this.parse(str); }
    return this;
  }

  Transform.prototype = {
    // ### setFromString()
    // Sets a property from a string.
    //
    //     t.setFromString('scale', '2,4');
    //     // Same as set('scale', '2', '4');
    //
    setFromString: function(prop, val) {
      var args =
        (typeof val === 'string')  ? val.split(',') :
        (val.constructor === Array) ? val :
        [ val ];

      args.unshift(prop);

      Transform.prototype.set.apply(this, args);
    },

    // ### set()
    // Sets a property.
    //
    //     t.set('scale', 2, 4);
    //
    set: function(prop) {
      var args = Array.prototype.slice.apply(arguments, [1]);
      if (this.setter[prop]) {
        this.setter[prop].apply(this, args);
      } else {
        this[prop] = args.join(',');
      }
    },

    get: function(prop) {
      if (this.getter[prop]) {
        return this.getter[prop].apply(this);
      } else {
        return this[prop] || 0;
      }
    },

    setter: {
      // ### rotate
      //
      //     .css({ rotate: 30 })
      //     .css({ rotate: "30" })
      //     .css({ rotate: "30deg" })
      //     .css({ rotate: "30deg" })
      //
      rotate: function(theta) {
        this.rotate = unit(theta, 'deg');
      },

      rotateX: function(theta) {
        this.rotateX = unit(theta, 'deg');
      },

      rotateY: function(theta) {
        this.rotateY = unit(theta, 'deg');
      },

      // ### scale
      //
      //     .css({ scale: 9 })      //=> "scale(9,9)"
      //     .css({ scale: '3,2' })  //=> "scale(3,2)"
      //
      scale: function(x, y) {
        if (y === undefined) { y = x; }
        this.scale = x + "," + y;
      },

      // ### skewX + skewY
      skewX: function(x) {
        this.skewX = unit(x, 'deg');
      },

      skewY: function(y) {
        this.skewY = unit(y, 'deg');
      },

      // ### perspectvie
      perspective: function(dist) {
        this.perspective = unit(dist, 'px');
      },

      // ### x / y
      // Translations. Notice how this keeps the other value.
      //
      //     .css({ x: 4 })       //=> "translate(4px, 0)"
      //     .css({ y: 10 })      //=> "translate(4px, 10px)"
      //
      x: function(x) {
        this.set('translate', x, null);
      },

      y: function(y) {
        this.set('translate', null, y);
      },

      // ### translate
      // Notice how this keeps the other value.
      //
      //     .css({ translate: '2, 5' })    //=> "translate(2px, 5px)"
      //
      translate: function(x, y) {
        if (this._translateX === undefined) { this._translateX = 0; }
        if (this._translateY === undefined) { this._translateY = 0; }

        if (x !== null) { this._translateX = unit(x, 'px'); }
        if (y !== null) { this._translateY = unit(y, 'px'); }

        this.translate = this._translateX + "," + this._translateY;
      }
    },

    getter: {
      x: function() {
        return this._translateX || 0;
      },

      y: function() {
        return this._translateY || 0;
      },

      scale: function() {
        var s = (this.scale || "1,1").split(',');
        if (s[0]) { s[0] = parseFloat(s[0]); }
        if (s[1]) { s[1] = parseFloat(s[1]); }

        // "2.5,2.5" => 2.5
        // "2.5,1" => [2.5,1]
        return (s[0] === s[1]) ? s[0] : s;
      },

      rotate3d: function() {
        var s = (this.rotate3d || "0,0,0,0deg").split(',');
        for (var i=0; i<=3; ++i) {
          if (s[i]) { s[i] = parseFloat(s[i]); }
        }
        if (s[3]) { s[3] = unit(s[3], 'deg'); }

        return s;
      }
    },

    // ### parse()
    // Parses from a string. Called on constructor.
    parse: function(str) {
      var self = this;
      str.replace(/([a-zA-Z0-9]+)\((.*?)\)/g, function(x, prop, val) {
        self.setFromString(prop, val);
      });
    },

    // ### toString()
    // Converts to a `transition` CSS property string. If `use3d` is given,
    // it converts to a `-webkit-transition` CSS property string instead.
    toString: function(use3d) {
      var re = [];

      for (var i in this) {
        if (this.hasOwnProperty(i)) {
          // Don't use 3D transformations if the browser can't support it.
          if ((!support.transform3d) && (
            (i === 'rotateX') ||
            (i === 'rotateY') ||
            (i === 'perspective') ||
            (i === 'transformOrigin'))) { continue; }

          if (i[0] !== '_') {
            if (use3d && (i === 'scale')) {
              re.push(i + "3d(" + this[i] + ",1)");
            } else if (use3d && (i === 'translate')) {
              re.push(i + "3d(" + this[i] + ",0)");
            } else {
              re.push(i + "(" + this[i] + ")");
            }
          }
        }
      }

      return re.join(" ");
    }
  };

  function callOrQueue(self, queue, fn) {
    if (queue === true) {
      self.queue(fn);
    } else if (queue) {
      self.queue(queue, fn);
    } else {
      fn();
    }
  }

  // ### getProperties(dict)
  // Returns properties (for `transition-property`) for dictionary `props`. The
  // value of `props` is what you would expect in `$.css(...)`.
  function getProperties(props) {
    var re = [];

    $.each(props, function(key) {
      key = $.camelCase(key); // Convert "text-align" => "textAlign"
      key = $.transit.propertyMap[key] || key;
      key = uncamel(key); // Convert back to dasherized

      if ($.inArray(key, re) === -1) { re.push(key); }
    });

    return re;
  }

  // ### getTransition()
  // Returns the transition string to be used for the `transition` CSS property.
  //
  // Example:
  //
  //     getTransition({ opacity: 1, rotate: 30 }, 500, 'ease');
  //     //=> 'opacity 500ms ease, -webkit-transform 500ms ease'
  //
  function getTransition(properties, duration, easing, delay) {
    // Get the CSS properties needed.
    var props = getProperties(properties);

    // Account for aliases (`in` => `ease-in`).
    if ($.cssEase[easing]) { easing = $.cssEase[easing]; }

    // Build the duration/easing/delay attributes for it.
    var attribs = '' + toMS(duration) + ' ' + easing;
    if (parseInt(delay, 10) > 0) { attribs += ' ' + toMS(delay); }

    // For more properties, add them this way:
    // "margin 200ms ease, padding 200ms ease, ..."
    var transitions = [];
    $.each(props, function(i, name) {
      transitions.push(name + ' ' + attribs);
    });

    return transitions.join(', ');
  }

  // ## $.fn.transition
  // Works like $.fn.animate(), but uses CSS transitions.
  //
  //     $("...").transition({ opacity: 0.1, scale: 0.3 });
  //
  //     // Specific duration
  //     $("...").transition({ opacity: 0.1, scale: 0.3 }, 500);
  //
  //     // With duration and easing
  //     $("...").transition({ opacity: 0.1, scale: 0.3 }, 500, 'in');
  //
  //     // With callback
  //     $("...").transition({ opacity: 0.1, scale: 0.3 }, function() { ... });
  //
  //     // With everything
  //     $("...").transition({ opacity: 0.1, scale: 0.3 }, 500, 'in', function() { ... });
  //
  //     // Alternate syntax
  //     $("...").transition({
  //       opacity: 0.1,
  //       duration: 200,
  //       delay: 40,
  //       easing: 'in',
  //       complete: function() { /* ... */ }
  //      });
  //
  $.fn.transition = $.fn.transit = function(properties, duration, easing, callback) {
    var self  = this;
    var delay = 0;
    var queue = true;

    // Account for `.transition(properties, callback)`.
    if (typeof duration === 'function') {
      callback = duration;
      duration = undefined;
    }

    // Account for `.transition(properties, duration, callback)`.
    if (typeof easing === 'function') {
      callback = easing;
      easing = undefined;
    }

    // Alternate syntax.
    if (typeof properties.easing !== 'undefined') {
      easing = properties.easing;
      delete properties.easing;
    }

    if (typeof properties.duration !== 'undefined') {
      duration = properties.duration;
      delete properties.duration;
    }

    if (typeof properties.complete !== 'undefined') {
      callback = properties.complete;
      delete properties.complete;
    }

    if (typeof properties.queue !== 'undefined') {
      queue = properties.queue;
      delete properties.queue;
    }

    if (typeof properties.delay !== 'undefined') {
      delay = properties.delay;
      delete properties.delay;
    }

    // Set defaults. (`400` duration, `ease` easing)
    if (typeof duration === 'undefined') { duration = $.fx.speeds._default; }
    if (typeof easing === 'undefined')   { easing = $.cssEase._default; }

    duration = toMS(duration);

    // Build the `transition` property.
    var transitionValue = getTransition(properties, duration, easing, delay);

    // Compute delay until callback.
    // If this becomes 0, don't bother setting the transition property.
    var work = $.transit.enabled && support.transition;
    var i = work ? (parseInt(duration, 10) + parseInt(delay, 10)) : 0;

    // If there's nothing to do...
    if (i === 0) {
      var fn = function(next) {
        self.css(properties);
        if (callback) { callback.apply(self); }
        if (next) { next(); }
      };

      callOrQueue(self, queue, fn);
      return self;
    }

    // Save the old transitions of each element so we can restore it later.
    var oldTransitions = {};

    var run = function(nextCall) {
      var bound = false;

      // Prepare the callback.
      var cb = function() {
        if (bound) { self.unbind(transitionEnd, cb); }

        if (i > 0) {
          self.each(function() {
            this.style[support.transition] = (oldTransitions[this] || null);
          });
        }

        if (typeof callback === 'function') { callback.apply(self); }
        if (typeof nextCall === 'function') { nextCall(); }
      };

      if ((i > 0) && (transitionEnd) && ($.transit.useTransitionEnd)) {
        // Use the 'transitionend' event if it's available.
        bound = true;
        self.bind(transitionEnd, cb);
      } else {
        // Fallback to timers if the 'transitionend' event isn't supported.
        window.setTimeout(cb, i);
      }

      // Apply transitions.
      self.each(function() {
        if (i > 0) {
          this.style[support.transition] = transitionValue;
        }
        $(this).css(properties);
      });
    };

    // Defer running. This allows the browser to paint any pending CSS it hasn't
    // painted yet before doing the transitions.
    var deferredRun = function(next) {
      var i = 0;

      // Durations that are too slow will get transitions mixed up.
      // (Tested on Mac/FF 7.0.1)
      if ((support.transition === 'MozTransition') && (i < 25)) { i = 25; }

      window.setTimeout(function() { run(next); }, i);
    };

    // Use jQuery's fx queue.
    callOrQueue(self, queue, deferredRun);

    // Chainability.
    return this;
  };

  function registerCssHook(prop, isPixels) {
    // For certain properties, the 'px' should not be implied.
    if (!isPixels) { $.cssNumber[prop] = true; }

    $.transit.propertyMap[prop] = support.transform;

    $.cssHooks[prop] = {
      get: function(elem) {
        var t = ($(elem).css('transform') && $(elem).css('transform') != 'none') ? $(elem).css('transform') : new Transform();
        return t.get(prop);
      },

      set: function(elem, value) {
        var t = ($(elem).css('transform') && $(elem).css('transform') != 'none') ? $(elem).css('transform') : new Transform();
        t.setFromString(prop, value);

        $(elem).css({ transform: t });
      }
    };
  }

  // ### uncamel(str)
  // Converts a camelcase string to a dasherized string.
  // (`marginLeft` => `margin-left`)
  function uncamel(str) {
    return str.replace(/([A-Z])/g, function(letter) { return '-' + letter.toLowerCase(); });
  }

  // ### unit(number, unit)
  // Ensures that number `number` has a unit. If no unit is found, assume the
  // default is `unit`.
  //
  //     unit(2, 'px')          //=> "2px"
  //     unit("30deg", 'rad')   //=> "30deg"
  //
  function unit(i, units) {
    if ((typeof i === "string") && (!i.match(/^[\-0-9\.]+$/))) {
      return i;
    } else {
      return "" + i + units;
    }
  }

  // ### toMS(duration)
  // Converts given `duration` to a millisecond string.
  //
  //     toMS('fast')   //=> '400ms'
  //     toMS(10)       //=> '10ms'
  //
  function toMS(duration) {
    var i = duration;

    // Allow for string durations like 'fast'.
    if ($.fx.speeds[i]) { i = $.fx.speeds[i]; }

    return unit(i, 'ms');
  }

  // Export some functions for testable-ness.
  $.transit.getTransitionValue = getTransition;

  /**
   * Slideshowify is a super easy-to-use jQuery plugin for generating image slideshows 
   * with a Ken Burns Effect, where images which don't fit the screen exactly 
   * (generally the case) are cropped and either panned across the screen or 
   * zoomed in a randomly determined direction.
   * 
   * Author: Aleksandar Kolundzija 
   * version 0.9.3
   *
   * @requires jquery
   * @requires jquery.transit (http://ricostacruz.com/jquery.transit/) as of version 0.9
   *
   * (The MIT License)
   *
   * Copyright (c) 2012 Aleksandar Kolundzija (a@ak.rs)
   *
   * Permission is hereby granted, free of charge, to any person obtaining
   * a copy of this software and associated documentation files (the
   * 'Software'), to deal in the Software without restriction, including
   * without limitation the rights to use, copy, modify, merge, publish,
   * distribute, sublicense, and/or sell copies of the Software, and to
   * permit persons to whom the Software is furnished to do so, subject to
   * the following conditions:
   *
   * The above copyright notice and this permission notice shall be
   * included in all copies or substantial portions of the Software.
   *
   * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
   * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
   * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
   */

  $.fn.slideshowify = function(/* config */){

    var _self         = this,
      _imgs         = [],
      _imgIndex     = -1, 
      _imgIndexNext = 0,        // for preloading next      
      _transition   = true,     // use CSS3 transitions (default might be changed during init)
      _easing       = 'in-out',
      _viewEl       = document, // filled by slideshow (used for determining dimensions)
      _containerId  = "slideshowify-" + new Date().getTime(),
      _containerCSS = {
        "position" : "absolute",
        "overflow" : "hidden",
        "z-index"  : "-2",
        "left"     : "0",
        "top"      : "0",
        "width"    : "100%",
        "height"   : "100%"
      },
      _cfg = {
        parentEl      : "body",   // slideshow-container is injected into this
        blend         : "into",   // "into" || "toBg"
        randomize     : false,
        fadeInSpeed   : 1500,
        fadeOutSpeed  : 1500,
        aniSpeedMin   : 9000, 
        aniSpeedMax   : 15000
      },
      _$viewEl,
      _$parentEl;


    if (arguments[0]){
      $.extend(_cfg, arguments[0]); // reconfigure
      if (_cfg.parentEl != "body") {
        _viewEl = _cfg.parentEl;
      }
    }

    // local refs
    _$viewEl   = $(_viewEl);
    _$parentEl = $(_cfg.parentEl);


    /**
     * Fill viewEl with image (most likely cropped based on its dimensions and view size).
     * @TODO Add support for target divs whose dimensions were set with %s (get px value from parents).
     * @TODO Add a window resize handler (adjust photo dims/margins).
     */
    function _revealImg(curImg){
      var $img            = $(this),
        viewW           = _$viewEl.width(),
        viewH           = _$viewEl.height(),
        viewRatio       = viewW/viewH,
        imgRatio        = $img.width()/$img.height(),
        marginThreshold = Math.floor(Math.max(viewW, viewH)/10), // for zoom transitions
        direction       = Math.round(Math.random()),
        transAttr       = {},
        transProps,
        marginPixels,
        modDims; // will hold values to set and animate

      if (imgRatio > viewRatio){
        modDims = _transition ? 
              direction ? {dim:'left', attr:'x', sign:'-'} : {dim:'right', attr:'x', sign:''} 
              :
              direction ? {dim:'left', attr:'left', sign:'-'} : {dim:'right', attr:'right', sign:'-'};
        $img.height(viewH + 'px').width(curImg.w * (viewH/curImg.h) + 'px');      
        marginPixels = $img.width() - viewW;
      }
      else {
        modDims = _transition ? 
              direction ? {dim:'top', attr:'y', sign:'-'} : {dim:'bottom', attr:'y', sign:''} 
              :
              direction ? {dim:'top', attr:'top', sign:'-'} : {dim:'bottom', attr:'bottom', sign:'-'};
        $img.width(viewW+'px').height(curImg.h * (viewW/curImg.w) + 'px');
        marginPixels = $img.height() - viewH;
      }
      $img.css(modDims.dim, '0');
      transAttr[modDims.attr] = modDims.sign + marginPixels + 'px'; 

      // if marginThreshold is small, zoom a little instead of panning
      if (_transition && marginPixels < marginThreshold){
        if (direction){ // zoom out 
          $img.css('scale','1.2');
          transAttr = {'scale':'1'};
        }
        else { // zoom in
          transAttr = {'scale':'1.2'};
        }
      }

      transProps = {
        duration : Math.min(Math.max(marginPixels * 10, _cfg.aniSpeedMin), _cfg.aniSpeedMax),
        easing   : _easing,
        queue    : false, 
        complete : function(){
          _$parentEl.trigger('beforeFadeOut', _imgs[_imgIndex])
          $img.fadeOut(_cfg.fadeOutSpeed, function(){
            _$parentEl.trigger('afterFadeOut', _imgs[_imgIndex]);
            $img.remove();
          });
          _loadImg();

        }
      };

      _$parentEl.trigger('beforeFadeIn', _imgs[_imgIndex]);
      $img.fadeIn(_cfg.fadeInSpeed, function(){
          $img.css('z-index', -1);
          _$parentEl.trigger('afterFadeIn', _imgs[_imgIndex])
        });

      // use animate if css3 transitions aren't supported
      _transition ? 
        $img.transition($.extend(transAttr, transProps)) :
        $img.animate(transAttr, transProps);
    } // end of _revealImg()


    /**
     * Loads image and starts display flow
     */
    function _loadImg(){
      var img     = new Image(),
        nextImg = new Image(), // for preloading
        len     = _imgs.length;

      _imgIndex = (_imgIndex < len-1) ? _imgIndex+1 : 0;

      $(img)
        // assign handlers
        .load(function(){
          if (_cfg.blend==='into'){
            $(this).css({'position':'absolute', 'z-index':'-2'});
            $('#'+_containerId).append(this);
          }
          else { // @TODO verify that this works
            $('#'+_containerId).empty().append(this);
          }
          _revealImg.call(this, _imgs[_imgIndex]);
        })
        .error(function(){
          throw new Error("Oops, can't load the image.");
        })
        .hide()
        .attr("src", _imgs[_imgIndex].src); // load

      if (_imgIndexNext == len) return; // nothing left to preload

      // preload next image
      _imgIndexNext = _imgIndex + 1;
      if (_imgIndexNext < len-1){
        nextImg.src = _imgs[_imgIndexNext].src;
      }
    } // end of _loadImg()


    // INITIALIZE
    if (!$.support.transition) {
          _transition = false;
          _easing = 'swing';
        }


      if (!_cfg.imgs){ // images were passed as selector 
      // load images into private array
      $(this).each(function(i, img){
        $(img).hide();
        _imgs.push({
          src : $(img).attr('src'),
          w   : $(img).width(),
          h   : $(img).height()
        });
      });
    }
    else {
      _imgs = _cfg.imgs;
    }


    if (_cfg.randomize){ 
      _imgs.sort(function(){ return 0.5 - Math.random(); });
    }


    // create container div 
    $("<div id='"+_containerId+"'></div>")
      .css(_containerCSS)
      .appendTo(_cfg.parentEl);


    // start
    _loadImg();

    return this;
  };

  /**
   * Expose slideshowify() to jQuery for use without DOM selector.
   */ 
  $.slideshowify = function(cfg){
    var _self = this,
      _cfg  = {
        dataUrl  : "",
        dataType : "json",
        async    : true,
        filterFn : function(data){ return data; } // default filter. does nothing
      };

    $.extend(_cfg, cfg);

    $.ajax({
      url      : _cfg.dataUrl,
      dataType : _cfg.dataType,
      async    : _cfg.async,
      success  : function(imgs){
        _cfg.imgs = _cfg.filterFn(imgs);      
        $({}).slideshowify(_cfg);
      }
    });
  };
}));