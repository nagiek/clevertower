define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/manage.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<section class="section">\n  <div class="row">\n    <div class="span8">\n      <header>\n        <h2 class="inline-block">' +
((__t = ( i18nCommon.classes.Properties )) == null ? '' : __t) +
'</h2>\n        <ul class="unstyled inline inline-block">\n        <li><button id="new-property" class="btn btn-success">\n          <i class="icon icon-white icon-plus"></i>\n          ' +
((__t = ( i18nProperty.actions.new_property )) == null ? '' : __t) +
'\n        </button></li>\n        </ul>\n      </header>\n      <ul id="network-properties" class="property-list unstyled">\n        <img src=\'/img/misc/spinner.gif\' class=\'spinner\' alt="' +
((__t = ( i18nCommon.verbs.loading )) == null ? '' : __t) +
'" />\n      </ul>\n    </div>\n    <div class="span4">\n      <ul class="nav nav-list well">\n        <li>\n          <a class="pull-right text-right" href="/network/edit" rel="tooltip" data-original-title="' +
((__t = ( i18nCommon.actions.edit )) == null ? '' : __t) +
'"><i class="icon icon-edit"></i></a>\n          \n          <a href="//clevertower.dev/networks/' +
((__t = ( name )) == null ? '' : __t) +
'">\n            <h4>' +
((__t = ( title )) == null ? '' : __t) +
'</h4>\n            <small>' +
((__t = ( i18nCommon.actions.go_to )) == null ? '' : __t) +
' clevertower.com/networks/' +
((__t = ( name )) == null ? '' : __t) +
'</small>\n          </a>\n        </li>\n        <li><a href="/network/managers">' +
((__t = ( i18nCommon.classes.Managers )) == null ? '' : __t) +
'</a></li>\n      </ul>\n    </div>\n  </div>\n</section>\n<div class="row wizard"></div>';

}
return __p
};

  return this["JST"];
});