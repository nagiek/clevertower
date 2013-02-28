define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/summary.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<li>\n  <div class="view">\n    <label class="property-content">' +
((__t = ( title )) == null ? '' : __t) +
'</label>\n    <button class="property-destroy"></button>\n  </div>\n</li>\n';

}
return __p
};

  return this["JST"];
});