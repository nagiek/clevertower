this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/photo/pending.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<!-- The template to display files available for upload -->\n';
 for (var i=0, file; file=files[i]; i++) { ;
__p += '\n  <div class="photo template-upload span4">\n    <div class="preview row"><span class="fade"></span></div>\n    <div class="progress progress-success progress-striped active"\n         role="progressbar"\n         aria-valuemin="0"\n         aria-valuemax="100"\n         aria-valuenow="0">\n      <div class="bar" style="width:0%;"></div>\n    </div>\n    <div class="photo-actions hide">\n      <button class="start btn" title="' +
((__t = ( i18nCommon.actions.start )) == null ? '' : __t) +
'">\n        <i class="icon-upload"></i>\n      </button>\n      <button class="cancel btn btn-warning" title="' +
((__t = ( i18nCommon.actions.cancel )) == null ? '' : __t) +
'">\n        <i class="icon-ban-circle icon-white"></i>\n      </button>\n      <!-- <input type="checkbox" name="delete" value="1"> -->\n    </div>\n  </div>\n';
 } ;


}
return __p
};