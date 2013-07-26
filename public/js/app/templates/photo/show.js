this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/photo/show.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<!-- The template to display files available for upload -->\n<div class="photo template-upload">\n  <img src="' +
((__t = ( url )) == null ? '' : __t) +
'" class="span4 fade in" width="370">\n  <div class="photo-actions">\n    <button type="button" class="photo-destroy btn btn-danger" title="' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'">\n      <i class="icon-trash icon-white"></i>\n    </button>\n    <!-- <input type="checkbox" name="delete" value="1"> -->\n  </div>\n</div>';

}
return __p
};