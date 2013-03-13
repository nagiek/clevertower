(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'collections/property/PropertyList', "models/Property", "views/property/summary", "i18n!nls/property", "i18n!nls/common", "templates/property/manage", "templates/property/menu", "templates/property/menu/show", "templates/property/menu/reports", "templates/property/menu/other", "templates/property/menu/actions"], function($, _, Parse, PropertyList, Property, PropertyView, i18nProperty, i18nCommon) {
    var ManagePropertiesView;
    return ManagePropertiesView = (function(_super) {

      __extends(ManagePropertiesView, _super);

      function ManagePropertiesView() {
        this.addAll = __bind(this.addAll, this);

        this.addOne = __bind(this.addOne, this);

        this.render = __bind(this.render, this);
        return ManagePropertiesView.__super__.constructor.apply(this, arguments);
      }

      ManagePropertiesView.prototype.el = "#main";

      ManagePropertiesView.prototype.events = {
        'click #new-property': "newProperty"
      };

      ManagePropertiesView.prototype.initialize = function() {
        this.$el.html(JST["src/js/templates/property/manage.jst"]({
          i18nProperty: i18nProperty
        }));
        _.bindAll(this, 'newProperty');
        this.$list = this.$el.find("ul#view-id-my_properties");
        this.properties = new PropertyList;
        this.properties.query = new Parse.Query(Property);
        this.properties.query.equalTo("user", Parse.User.current());
        this.properties.bind("add", this.addOne);
        this.properties.bind("reset", this.addAll);
        this.properties.bind("all", this.render);
        return this.properties.fetch();
      };

      ManagePropertiesView.prototype.render = function() {};

      ManagePropertiesView.prototype.addOne = function(property) {
        var view;
        if (this.properties.length === 0) {
          this.$list.html('');
        }
        view = new PropertyView({
          model: property
        });
        return this.$list.append(view.render().el);
      };

      ManagePropertiesView.prototype.addAll = function(collection, filter) {
        this.$list.html("");
        if (this.properties.length !== 0) {
          this.properties.each(this.addOne);
          this.$list.children(':even').addClass('views-row-even');
          return this.$list.children(':odd').addClass('views-row-odd');
        } else {
          return this.$list.html('<p class="empty">' + i18nProperty.collection.empty + '</p>');
        }
      };

      ManagePropertiesView.prototype.newProperty = function() {
        var _this = this;
        return require(["views/property/Wizard"], function(PropertyWizard) {
          var propertyWizard;
          _this.$el.find("#new-property").prop({
            disabled: "disabled"
          });
          _this.$el.find("section").hide();
          propertyWizard = new PropertyWizard;
          Parse.history.navigate("/properties/new");
          propertyWizard.on("wizard:cancel", function(property) {
            _this.$el.find("#new-property").removeProp("disabled");
            _this.$el.append('<div id="form" class="wizard"></div>');
            return _this.$el.find("section").show();
          });
          return propertyWizard.on("property:save", function(property) {
            _this.properties.add(property);
            _this.$el.find("#new-property").removeProp("disabled");
            _this.$el.append('<div id="form" class="wizard"></div>');
            return _this.$el.find("section").show();
          });
        });
      };

      return ManagePropertiesView;

    })(Parse.View);
  });

}).call(this);
