this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/property/show.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<div id="property" class="container">\n  <div class="page-header clearfix">    \n    <div class="photo photo-thumbnail photo-elastic pull-left tablet-left">\n      <a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'">\n        <img src="' +
((__t = ( cover )) == null ? '' : __t) +
'" alt="Profile" class="img-rounded profile-picture">\n      </a>\n      <div class="photo-actions hide">\n        <button role="button" class="btn btn-small edit-profile-picture" title="' +
((__t = ( i18nCommon.actions.edit )) == null ? '' : __t) +
'">\n          <i class="icon-edit"></i>\n        </button>\n      </div>\n    </div>\n    \n    <header class="header photo-float thumbnail-float elastic-float">\n      <h1 class="inline-block profile-inline">\n        <a href="/properties/' +
((__t = ( objectId )) == null ? '' : __t) +
'">' +
((__t = ( title )) == null ? '' : __t) +
'</a>\n      </h1>\n\n      <ul class="nav nav-tabs inline-block profile-inline" role="navigation">\n        <li class="dropdown">\n          <a href="#" class="dropdown-toggle" data-toggle="dropdown">\n            ' +
((__t = ( i18nProperty.menu.day_to_day )) == null ? '' : __t) +
'\n            <b class="caret"></b>\n          </a>\n          ' +
((__t = ( JST["src/js/templates/property/menu/show.jst"]({objectId: objectId, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n        </li>\n        <li class="dropdown">\n          <a href="#" class="dropdown-toggle" data-toggle="dropdown">\n            ' +
((__t = ( i18nProperty.menu.building )) == null ? '' : __t) +
'\n            <b class="caret"></b>\n          </a>\n          ' +
((__t = ( JST["src/js/templates/property/menu/building.jst"]({publicUrl: publicUrl, objectId: objectId, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n        </li>\n        <li class="dropdown">\n          <a href="#" class="dropdown-toggle" data-toggle="dropdown">\n            ' +
((__t = ( i18nProperty.menu.reports )) == null ? '' : __t) +
'\n            <b class="caret"></b>\n          </a>\n          ' +
((__t = ( JST["src/js/templates/property/menu/reports.jst"]({objectId: objectId, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n        </li>\n        <li class="dropdown add-dropdown">\n          <a href="#" class="btn.btn-success dropdown-toggle" data-toggle="dropdown">\n            ' +
((__t = ( i18nProperty.menu.actions )) == null ? '' : __t) +
'\n            <b class="caret"></b>\n          </a>\n          ' +
((__t = ( JST["src/js/templates/property/menu/actions.jst"]({objectId: objectId, i18nProperty: i18nProperty}) )) == null ? '' : __t) +
'\n        </li>\n      </ul>\n    </header>\n  </div>\n\n  <div class="content fade"></div>\n</div>\n\n<div id="edit-profile-picture-modal" class="modal form-modal hide fade">\n  <form id="profile-picture-upload-form" method="POST">\n    <div class="modal-header">\n      <button type="button" class="close" data-dismiss="modal" aria-labelledby="edit-profile-picture-modal-label" aria-hidden="true">&times;</button>\n      <h3 id="edit-profile-picture-modal-label">' +
((__t = ( i18nProperty.actions.edit_picture )) == null ? '' : __t) +
'</h3>\n    </div>\n    <div class="modal-body">\n      <div class="row-fluid">\n        <div id="preview-profile-picture" class="preview template-upload">\n          <img src="' +
((__t = ( cover )) == null ? '' : __t) +
'" alt="Profile" class="profile-picture span4 offset1">\n        </div>\n        <div id="profile-picture-controls" class="span6 offset1">\n          <div id="preview-profile-picture-name"></div>\n          <div class="fileupload-buttonbar">\n            <button type="button" id="file-input" class="btn fileinput-button">\n                <span>' +
((__t = ( i18nCommon.actions.choose_file )) == null ? '' : __t) +
'</span>\n                <input type="file" name="files[]" accept="photo/*">\n            </button>\n          </div>\n          <!-- The global progress information -->\n          <div class="fileupload-progress fade hide">\n\n            <!-- The global progress bar -->\n            <div class="progress progress-success progress-striped active"\n              role="progressbar"\n              aria-valuemin="0"\n              aria-valuemax="100">\n              <div class="bar" style="width:0%;"></div>\n            </div>\n            <!-- The extended global progress information -->\n            <div class="progress-extended">&nbsp;</div>\n            \n          </div>\n\n          <!-- The loading indicator is shown during file processing -->\n          <div class="fileupload-loading"></div>\n        </div>\n      </div>    \n    </div>\n    <div class="modal-footer">\n      <button class="start btn btn-primary">' +
((__t = ( i18nCommon.actions.upload )) == null ? '' : __t) +
'</button>\n      <button class="btn" data-dismiss="modal">' +
((__t = ( i18nCommon.actions.close )) == null ? '' : __t) +
'</button>\n    </div>\n  </form>\n</div>';

}
return __p
};