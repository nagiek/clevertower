this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/sub/photos.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<form id="fileupload">\n  <div class="form-actions fileupload-buttonbar">\n    <button type="button" id="file-input" class="btn btn-success fileinput-button">\n        <i class="glyphicon glyphicon-plus"></i>\n        <span>' +
((__t = ( i18nCommon.actions.add_photos )) == null ? '' : __t) +
'</span>\n        <input type="file" name="files[]" accept="photo/*"  multiple>\n    </button>\n    <!-- The fileinput-button span is used to style the file input field as button -->\n    <button type="submit" id="upload" class="start btn btn-primary">\n      <span>' +
((__t = ( i18nCommon.actions.upload )) == null ? '' : __t) +
'</span>\n    </button>\n    <!-- <button type="button" class="btn btn-danger delete" disabled="disabled">\n      <i class="glyphicon glyphicon-trash icon-white"></i>\n      <span>' +
((__t = ( i18nCommon.actions.delete )) == null ? '' : __t) +
'</span>\n    </button>\n    <input type="checkbox" class="toggle"> -->\n    <!-- <button type="reset" class="btn btn-default cancel">\n      <span>' +
((__t = ( i18nCommon.actions.cancel )) == null ? '' : __t) +
'</span>\n    </button> -->\n  </div>\n\n  <!-- The global progress information -->\n  <div class="fileupload-progress fade hide">\n    \n    <!-- The global progress bar -->\n    <div class="progress progress-success progress-striped active"\n      role="progressbar"\n      aria-valuemin="0"\n      aria-valuemax="100">\n      <div class="bar" style="width:0%;"></div>\n    </div>\n    <!-- The extended global progress information -->\n    <div class="progress-extended">&nbsp;</div>\n  </div>\n\n  <!-- The loading indicator is shown during file processing -->\n  <div class="fileupload-loading"></div>\n\n  <!-- The table listing the files available for upload/download -->\n  <ul id="non-uploaded-photo-list" class="row list-unstyled" role="presentation"></ul>\n\n  <ul id="photo-list" class="row list-unstyled">\n    <li><img src=\'/img/misc/spinner.gif\' class=\'spinner\' alt="' +
((__t = ( i18nCommon.verbs.loading )) == null ? '' : __t) +
'" /></li>\n  </ul>\n</form>';

}
return __p
};