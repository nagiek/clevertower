this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/todo/stats.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<footer id="footer">\n  <span id="todo-count">\n    <strong>' +
((__t = ( remaining )) == null ? '' : __t) +
'</strong> \n    ' +
((__t = ( remaining == 1 ? 'item' : 'items' )) == null ? '' : __t) +
' left\n  </span>\n  <ul id="filters">\n    <li><a id="all" class="selected">All</a></li>\n    <li><a id="active">Active</a></li>\n    <li><a id="completed">Completed</a></li>\n  </ul>\n  <button id="clear-completed">Clear completed (' +
((__t = ( done )) == null ? '' : __t) +
')</button>\n</footer>\n';

}
return __p
};