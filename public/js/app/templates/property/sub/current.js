define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/current.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<table id="current-units" class="table">\n  <thead>\n    <tr>\n      <th>' +
((__t = (i18nCommon.classes.Unit)) == null ? '' : __t) +
'</th>\n      <th>' +
((__t = (i18nUnit.fields.status)) == null ? '' : __t) +
'</th>\n      <th>' +
((__t = (i18nLease.attributes.ending)) == null ? '' : __t) +
'</th>\n      <th>' +
((__t = (i18nLease.attributes.rent_this_month)) == null ? '' : __t) +
'</th>\n      <th><span class="element-invisible">' +
((__t = (i18nCommon.headers.Operations)) == null ? '' : __t) +
'</span></th>\n    </tr>\n  </thead>\n  <tbody></tbody>\n</table>\n      ';

}
return __p
};

  return this["JST"];
});