define(function(){

this["JST"] = this["JST"] || {};

this["JST"]["src/js/templates/todo/manage.jst"] = function(obj) {
obj || (obj = {});
var __t, __p = '', __e = _.escape;
with (obj) {
__p += '<section class="section">\n  <header id="header">\n    <input id="new-todo" placeholder="What needs to be done?" type="text" />\n  </header>\n\n  <div id="main">\n    <input id="toggle-all" type="checkbox">\n    <label for="toggle-all">Mark all as complete</label>\n    \n    <ul id="todo-list">\n      <img src=\'/img/misc/spinner.gif\' class=\'spinner\' />\n    </ul>\n  </div>\n\n  <div id="todo-stats"></div>\n</section>';

}
return __p
};

  return this["JST"];
});