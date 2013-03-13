define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/file/upload.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape, __j = Array.prototype.join;
function print() { __p += __j.call(arguments, '') }
with (obj) {
__p += '<!-- The template to display files available for upload -->\n';
 for (var i=0, file; file=files[i]; i++) { ;
__p += '\n  <tr class="template-upload fade">\n    <td class="preview"><span class="fade"></span></td>\n    <td class="name"><span>' +
((__t = (file.name)) == null ? '' : __t) +
'</span></td>\n    <td class="size"><span>' +
((__t = (formatFileSize(file.size))) == null ? '' : __t) +
'</span></td>\n    ';
 if (file.error) { ;
__p += '\n      <td class="error" colspan="2"><span class="label label-important">Error</span> ' +
((__t = (file.error)) == null ? '' : __t) +
'</td>\n    ';
 } else if (files.valid && !i) { ;
__p += '\n      <td>\n        <div class="progress progress-success progress-striped active" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"><div class="bar" style="width:0%;"></div></div>\n      </td>\n      <td class="start">';
 if (!options.autoUpload) { ;
__p += '\n        <button class="btn btn-primary">\n          <i class="icon-upload icon-white"></i>\n          <span>Start</span>\n        </button>\n      ';
 } ;
__p += '</td>\n    ';
 } else { ;
__p += '\n      <td colspan="2"></td>\n    ';
 } ;
__p += '\n    <td class="cancel">';
 if (!i) { ;
__p += '\n      <button class="btn btn-warning">\n        <i class="icon-ban-circle icon-white"></i>\n        <span>Cancel</span>\n      </button>\n    ';
 } ;
__p += '</td>\n  </tr>\n';
 } ;


}
return __p
};

  return this["JST"];
});