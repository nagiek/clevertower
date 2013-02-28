define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/manage.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<section class="section">\n  <header>\n    <ul id="actions" class="unstyled inline">\n      <li>\n        <button id="new-property" class="btn btn-success">\n          ' +
((__t = ( i18nProperty.actions.new_property )) == null ? '' : __t) +
'\n        </button>\n      </li>\n    </ul>\n  </header>\n\n  <ul id="property-list">\n    <img src=\'/img/misc/spinner.gif\' class=\'spinner\' />\n  </ul>\n</section>\n\n<div id="form" class="wizard"></div>';

}
return __p
};

  return this["JST"];
});