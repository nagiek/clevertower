(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", "models/Property", "i18n!nls/property", "i18n!nls/common", "templates/property/sub/edit", 'templates/property/form/_basic'], function($, _, Parse, Property, i18nProperty, i18nCommon) {
    var PropertyEditView;
    return PropertyEditView = (function(_super) {

      __extends(PropertyEditView, _super);

      function PropertyEditView() {
        this.addOne = __bind(this.addOne, this);
        return PropertyEditView.__super__.constructor.apply(this, arguments);
      }

      PropertyEditView.prototype.el = "#content";

      PropertyEditView.prototype.events = {
        'click .save': 'save',
        'click .remove': 'kill'
      };

      PropertyEditView.prototype.initialize = function() {
        var _this = this;
        this.$el.append(JST["src/js/templates/property/sub/edit.jst"](_.merge({
          property: this.model,
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon
        })));
        _.bindAll(this, 'save');
        this.on("property:save", function() {
          return _this._clear();
        });
        return this.on("property:cancel", function() {
          return _this._clear();
        });
      };

      PropertyEditView.prototype.addOne = function(image) {
        var view;
        view = new ImageView({
          model: image
        });
        return this.$photos.append(view.render().el);
      };

      PropertyEditView.prototype.save = function(e) {
        e.preventDefault();
        if (this.unUploadedImages > 0) {
          return $("#fileupload").fileupload('send').done(this._save());
        } else {
          return this._save();
        }
      };

      PropertyEditView.prototype._save = function() {
        var _this = this;
        return this.model.save(this.$el.serializeObject().property, {
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

      PropertyEditView.prototype._return = function() {
        this.remove();
        this.undelegateEvents();
        delete this;
        return Parse.history.navigate("/properties/" + this.model.id);
      };

      PropertyEditView.prototype.kill = function() {
        if (confirm(i18nCommon.actions.confirm + " " + i18nCommon.warnings.no_undo)) {
          this.model.destroy();
          this.remove();
          this.undelegateEvents();
          delete this;
          return Parse.history.navigate("/");
        }
      };

      return PropertyEditView;

    })(Parse.View);
  });

}).call(this);
