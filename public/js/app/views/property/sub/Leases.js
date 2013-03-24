(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["jquery", "underscore", "backbone", 'collections/lease/LeaseList', 'models/Property', 'models/Lease', 'views/helper/Alert', 'views/lease/Summary', "i18n!nls/common", "i18n!nls/property", "i18n!nls/unit", "i18n!nls/lease", 'templates/property/sub/leases'], function($, _, Parse, LeaseList, Property, Lease, Alert, LeaseView, i18nCommon, i18nProperty, i18nUnit, i18nLease) {
    var PropertyLeasesView;
    return PropertyLeasesView = (function(_super) {

      __extends(PropertyLeasesView, _super);

      function PropertyLeasesView() {
        this.save = __bind(this.save, this);

        this.undo = __bind(this.undo, this);

        this.addX = __bind(this.addX, this);

        this.addOne = __bind(this.addOne, this);

        this.addAll = __bind(this.addAll, this);

        this.switchToEdit = __bind(this.switchToEdit, this);

        this.switchToShow = __bind(this.switchToShow, this);

        this.render = __bind(this.render, this);
        return PropertyLeasesView.__super__.constructor.apply(this, arguments);
      }

      PropertyLeasesView.prototype.el = "#content";

      PropertyLeasesView.prototype.events = {
        'click #leases-show a': 'switchToShow',
        'click #leases-edit a': 'switchToEdit',
        'click #add-x': 'addX',
        'click .undo': 'undo',
        'click .save': 'save'
      };

      PropertyLeasesView.prototype.initialize = function(attrs) {
        var vars;
        vars = _.merge({
          i18nProperty: i18nProperty,
          i18nCommon: i18nCommon,
          i18nUnit: i18nUnit,
          i18nLease: i18nLease
        });
        this.$el.html(JST["src/js/templates/property/sub/leases.jst"](vars));
        this.editing = false;
        this.$messages = $("#messages");
        this.$table = this.$("#leases-table");
        this.$list = this.$("#leases-table tbody");
        this.$actions = this.$(".form-actions");
        this.$undo = this.$actions.find('.undo');
        this.model.loadUnits();
        this.model.loadLeases();
        this.model.leases.on("add", this.addOne);
        this.model.leases.on("reset", this.addAll);
        return this.model.leases.fetch();
      };

      PropertyLeasesView.prototype.render = function() {
        this.$list.html("");
        if (this.model.leases.length === 0) {
          return this.$list.html('<p class="empty">' + i18nLease.collection.empty + '</p>');
        }
      };

      PropertyLeasesView.prototype.switchToShow = function(e) {
        e.preventDefault();
        if (!this.editing) {
          return;
        }
        this.$('ul.nav').children().removeClass('active');
        e.currentTarget.parentNode.className = 'active';
        this.$table.find('.view-specific').toggleClass('hide');
        this.$actions.toggleClass('hide');
        this.editing = false;
        return e;
      };

      PropertyLeasesView.prototype.switchToEdit = function(e) {
        e.preventDefault();
        if (this.editing) {
          return;
        }
        this.$('ul.nav').children().removeClass('active');
        e.currentTarget.parentNode.className = 'active';
        this.$table.find('.view-specific').toggleClass('hide');
        this.$actions.toggleClass('hide');
        this.editing = true;
        return e;
      };

      PropertyLeasesView.prototype.addAll = function(collection, filter) {
        this.$list.html('');
        this.render();
        return this.model.leases.each(this.addOne);
      };

      PropertyLeasesView.prototype.addOne = function(lease) {
        var title, unitId, view;
        this.$('p.empty').hide();
        unitId = lease.get("unit").id;
        title = this.model.units.get(unitId).get("title");
        view = new LeaseView({
          model: lease,
          title: title
        });
        this.$list.append(view.render().el);
        if (this.editing) {
          return view.$el.find('.view-specific').toggleClass('hide');
        }
      };

      PropertyLeasesView.prototype.addX = function(e) {
        var char, lease, newChar, newTitle, title, x;
        e.preventDefault();
        x = Number($('#x').val());
        if (x == null) {
          x = 1;
        }
        while (!(x <= 0)) {
          if (this.model.leases.length === 0) {
            lease = new Lease({
              property: this.model
            });
          } else {
            lease = this.model.leases.at(this.model.leases.length - 1).clone();
            title = lease.get('title');
            newTitle = title.substr(0, title.length - 1);
            char = title.charAt(title.length - 1);
            newChar = isNaN(char) ? String.fromCharCode(char.charCodeAt() + 1) : String(Number(char) + 1);
            lease.set('title', newTitle + newChar);
          }
          this.model.leases.add(lease);
          x--;
        }
        this.$undo.removeProp('disabled');
        return this.$list.last().find('.title-group input').focus();
      };

      PropertyLeasesView.prototype.undo = function(e) {
        var x;
        e.preventDefault();
        x = Number($('#x').val());
        if (x == null) {
          x = 1;
        }
        while (!(x <= 0)) {
          if (this.model.leases.length !== 0) {
            if (this.model.leases.last().isNew()) {
              this.model.leases.last().destroy();
            }
          }
          x--;
        }
        return this.$undo.prop('disabled', 'disabled');
      };

      PropertyLeasesView.prototype.save = function(e) {
        var _this = this;
        e.preventDefault();
        if (this.$('.error')) {
          this.$('.error').removeClass('error');
        }
        return this.model.leases.each(function(lease) {
          var error;
          if (lease.changed) {
            error = lease.validate(lease.attributes);
            if (!error) {
              return lease.save(null, {
                success: function(lease) {
                  new Alert({
                    event: 'leases-save',
                    fade: true,
                    message: i18nCommon.actions.changes_saved,
                    type: 'success'
                  });
                  if (lease.changed) {
                    return lease.trigger("save:success");
                  }
                },
                error: function(lease, error) {
                  return lease.trigger("invalid", lease, error);
                }
              });
            } else {
              return lease.trigger("invalid", lease, error);
            }
          }
        });
      };

      return PropertyLeasesView;

    })(Parse.View);
  });

}).call(this);
