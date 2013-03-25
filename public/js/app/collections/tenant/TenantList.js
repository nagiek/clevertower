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

      TenantList.prototype.initialize = function(attrs) {
        if (attrs && attrs.lease && attrs.lease.id) {
          return this.createQuery(attrs.lease);
        }
      };

      TenantList.prototype.createQuery = function(lease) {
        var innerQuery;
        if (lease) {
          this.lease = lease;
        }
        if (this.lease && this.lease.id) {
          this.query = new Parse.Query(Parse.User);
          innerQuery = new Parse.Query(Tenant);
          innerQuery.equalTo("lease", this.lease);
          return this.query.matchesQuery("tenant", innerQuery);
        }
      };

      return TenantList;

    })(Parse.Collection);
  });

}).call(this);
