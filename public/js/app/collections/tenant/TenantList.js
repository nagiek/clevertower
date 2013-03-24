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

      return TenantList;

    })(Parse.Collection);
  });

}).call(this);
