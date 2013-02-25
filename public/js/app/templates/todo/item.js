define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/todo/item.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<li class="' +
((__t = ( done ? 'completed' : '' )) == null ? '' : __t) +
'">\n  <div class="view">\n  <input class="toggle" type="checkbox" ' +
((__t = ( done ? 'checked="checked"' : '' )) == null ? '' : __t) +
'>\n  <label class="todo-content">' +
((__t = ( content )) == null ? '' : __t) +
'</label>\n  <button class="todo-destroy"></button>\n  </div>\n  <input class="edit" value="' +
((__t = ( content )) == null ? '' : __t) +
'">\n</li>\n';

}
return __p
};

  return this["JST"];
});