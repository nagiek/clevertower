(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/Property", "i18n!nls/property", "i18n!nls/common", "templates/property/edit"], function($, _, Parse, Property, i18nProperty, i18nCommon) {
    var PropertyEditView;
    return PropertyEditView = (function(_super) {

      __extends(PropertyEditView, _super);

      function PropertyEditView() {
        return PropertyEditView.__super__.constructor.apply(this, arguments);
      }

      PropertyEditView.prototype.el = "#form";

      PropertyEditView.prototype.events = {
        'click .back': 'back',
        'click .next': 'next',
        'click .cancel': 'cancel'
      };

      PropertyEditView.prototype.initialize = function() {
        var _this = this;
        this.$el.append(JST["src/js/templates/property/edit.jst"](_.merge(this.model.toJSON(), {
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        })));
        this.on("property:save", function() {
          _this.remove();
          _this.undelegateEvents();
          delete _this;
          return Parse.history.navigate('/');
        });
        this.on("property:cancel", function() {
          _this.remove();
          _this.undelegateEvents();
          delete _this;
          return Parse.history.navigate('/');
        });
        return _.bindAll(this, 'save', 'back');
      };

      PropertyEditView.prototype.save = function(e) {
        var _this = this;
        return this.model.save(this.form.$el.serializeObject().property, {
          success: function(property) {
            return _this.trigger("property:save", property, _this);
          },
          error: function(property, error) {
            _this.$el.find('.alert-error').html(i18nProperty.errors.messages[error.message]).show();
            _this.$el.find('.error').removeClass('error');
            switch (error.message) {
              case 'title_missing':
                return _this.$el.find('#property-title-group').addClass('error');
            }
          }
        });
      };

      PropertyEditView.prototype.back = function(e) {
        return this.trigger("wizard:cancel", this);
      };

      return PropertyEditView;

    })(Parse.View);
  });

}).call(this);
