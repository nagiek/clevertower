define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/file/download.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {

 for (var i=0, file; file=files[i]; i++) { ;
__p += '\n  <tr class="template-download fade">\n    ';
 if (file.error) { ;
__p += '\n      <td class="error" colspan="2"><span class="label label-important">Error</span> ' +
((__t = (file.error)) == null ? '' : __t) +
'</td>\n    ';
 } else { ;
__p += '\n      <td class="preview">';
 if (file.thumbnail_url) { ;
__p += '\n        <a href="' +
((__t = (file.thumbnail_url)) == null ? '' : __t) +
'" title="' +
((__t = (file.name)) == null ? '' : __t) +
'" data-gallery="gallery" download="' +
((__t = (file.name)) == null ? '' : __t) +
'"><img src="' +
((__t = (file.thumbnail_url)) == null ? '' : __t) +
'"></a>\n      ';
 } ;
__p += '</td>\n    ';
 } ;
__p += '\n    <td class="delete">\n      <button class="btn btn-danger">\n        <i class="icon-trash icon-white"></i>\n        <span>Delete</span>\n      </button>\n      <input type="checkbox" name="delete" value="1">\n    </td>\n  </tr>\n';
 } ;


}
return __p
};

  return this["JST"];
});