define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/tenant/summary.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div class="photo span">\n  <img src="' +
((__t = (url)) == null ? '' : __t) +
'" class="img-rounded photo-profile" width="100">\n  <div class="photo-actions hide">\n    <button class="photo-destroy btn btn-mini" title="' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'">\n      <strong>&times;</strong>\n    </button>\n    <a href="/users/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( first_name )) == null ? '' : __t) +
' ' +
((__t = ( last_name )) == null ? '' : __t) +
'</a>\n  </div>\n</div>';

}
return __p
};

  return this["JST"];
});