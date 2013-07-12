this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/photo/show.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<!-- The template to display files available for upload -->\n<li class="photo template-upload">\n  <div class="preview"></div>\n  <div class="progress progress-success progress-striped active"\n       role="progressbar"\n       aria-valuemin="0"\n       aria-valuemax="100"\n       aria-valuenow="0">\n    <div class="bar" style="width:0%;"></div>\n  </div>\n  <div class="photo-actions">\n    <button type="button" class="photo-destroy btn btn-danger" title="' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'">\n      <i class="icon-trash icon-white"></i>\n    </button>\n    <!-- <input type="checkbox" name="delete" value="1"> -->\n  </div>\n</li>';

}
return __p
};