(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'collections/property/PropertyList', "models/Network", "models/Property", "views/property/summary", "i18n!nls/property", "i18n!nls/common", "templates/property/manage", "templates/property/menu", "templates/property/menu/show", "templates/property/menu/reports", "templates/property/menu/building", "templates/property/menu/actions"], function($, _, Parse, PropertyList, Network, Property, SummaryPropertyView, i18nProperty, i18nCommon) {
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
        var _this = this;
        _.bindAll(this, 'newProperty');
        Parse.User.current().get("network").properties.on("add", this.addOne);
        Parse.User.current().get("network").properties.on("reset", this.addAll);
        Parse.User.current().get("network").properties.on("show", function() {
          return _this.$propertyList.hide();
        });
        return Parse.User.current().get("network").properties.on("close", function() {
          return _this.$propertyList.show();
        });
      };

      ManagePropertiesView.prototype.render = function() {
        var network, vars;
        network = Parse.User.current().get("network");
        _.defaults(network.attributes, Network.prototype.defaults);
        vars = _.merge(network.toJSON(), {
          i18nCommon: i18nCommon,
          i18nProperty: i18nProperty
        });
        this.$el.html(JST["src/js/templates/property/manage.jst"](vars));
        this.$propertyList = this.$("#network-properties");
        this.$managerList = this.$("#network-managers");
        if (Parse.User.current().get("network").properties.length === 0) {
          return Parse.User.current().get("network").properties.fetch({
            success: function(collection, resp, options) {
              var query;
              query = new Parse.Query("Unit");
              query.containedIn("property", collection.models);
              return query.count({
                success: function(number) {
                  return collection.each(function(property) {
                    return property.unitsLength = number;
                  });
                }
              });
            }
          });
        } else {
          return this.addAll();
        }
      };

      ManagePropertiesView.prototype.addOne = function(property) {
        var view;
        if (this.$('p.empty')) {
          this.$('p.empty').remove();
        }
        view = new SummaryPropertyView({
          model: property
        });
        return this.$propertyList.append(view.render().el);
      };

      ManagePropertiesView.prototype.addAll = function(collection, filter) {
        this.$propertyList.html("");
        if (Parse.User.current().get("network").properties.length !== 0) {
          Parse.User.current().get("network").properties.each(this.addOne);
          this.$propertyList.children(':even').children().addClass('views-row-even');
          return this.$propertyList.children(':odd').children().addClass('views-row-odd');
        } else {
          return this.$propertyList.html('<p class="empty">' + i18nProperty.collection.empty.properties + '</p>');
        }
      };

      ManagePropertiesView.prototype.newProperty = function() {
        var _this = this;
        return require(["views/property/new/Wizard"], function(PropertyWizard) {
          var propertyWizard;
          _this.$("#new-property").prop({
            disabled: "disabled"
          });
          _this.$("section").hide();
          propertyWizard = (new PropertyWizard).render();
          Parse.history.navigate("/properties/new");
          propertyWizard.on("wizard:cancel", function() {
            _this.$("#new-property").removeProp("disabled");
            return _this.$("section").show();
          });
          return propertyWizard.on("property:save", function(property) {
            Parse.User.current().get("network").properties.add(property);
            _this.$("#new-property").removeProp("disabled");
            return _this.$("section").show();
          });
        });
      };

      return ManagePropertiesView;

    })(Parse.View);
  });

}).call(this);
