(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'underscore', 'backbone', 'models/Tenant'], function($, _, Parse, Tenant) {
    var TenantList;
    return TenantList = (function(_super) {

      __extends(TenantList, _super);

      function TenantList() {
        return TenantList.__super__.constructor.apply(this, arguments);
      }

      TenantList.prototype.model = Tenant;

      TenantList.prototype.initialize = function(models, attrs) {
        this.lease = attrs.lease;
        this.network = attrs.network;
        this.property = attrs.property;
        return this.createQuery();
      };

      TenantList.prototype.createLeaseQuery = function(lease) {
        this.lease = lease;
        return this.createQuery();
      };

      TenantList.prototype.createPropertyQuery = function(property) {
        this.property = property;
        return this.createQuery();
      };

      TenantList.prototype.createNetworkQuery = function(network) {
        this.network = network;
        return this.createQuery();
      };

      TenantList.prototype.createQuery = function() {
        this.query = new Parse.Query(Tenant).include("profile");
        if (this.lease && this.lease.id) {
          this.query.equalTo("lease", this.lease);
        }
        if (this.property && this.property.id) {
          this.query.equalTo("property", this.property);
        }
        if (this.network && this.network.id) {
          return this.query.equalTo("network", this.network);
        }
      };

      return TenantList;

    })(Parse.Collection);
  });

}).call(this);
