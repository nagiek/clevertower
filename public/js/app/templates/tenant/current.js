define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/tenant/current.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class="photo template-download row fade in">\n  <img src="' +
((__t = (url)) == null ? '' : __t) +
'" class="img-rounded span4" width="370">\n  <div class="photo-actions hide">\n    <button class="photo-destroy btn btn-danger" title="' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'">\n      <i class="icon-trash icon-white"></i>\n    </button>\n    <!-- <input type="checkbox" name="delete" value="1"> -->\n  </div>\n</div>';

}
return __p
};

  return this["JST"];
});