(function() {

  Parse.Cloud.define("CheckForUniqueProperty", function(request, response) {
    return (new Parse.Query("Property")).equalTo("user", request.user).withinKilometers("center", request.params.center, 0.001).first({
      success: function(obj) {
        if (obj) {
          return response.error("" + obj.id + ":taken_by_user");
        }
        return response.success();
      },
      error: function() {
        return response.error('bad_query');
      }
    });
  });

  Parse.Cloud.beforeSave("Property", function(request, response) {
    request.object.set("user", request.user);
    if (!(+request.object.get("center") !== +Parse.GeoPoint())) {
      return response.error('invalid_address');
    } else if (!(request.object.get("thoroughfare") !== '' && request.object.get("locality") !== '' && request.object.get("administrative_area_level_1") !== '' && request.object.get("country") !== '' && request.object.get("postal_code") !== '')) {
      return response.error('insufficient_data');
    } else {
      if (request.object.get("title") == null) {
        return response.error('title_missing');
      }
    }
    return response.success();
  });

  Parse.Cloud.afterSave("Property", function(request) {
    var current, propertyACL;
    if (!request.object.existed()) {
      propertyACL = new Parse.ACL(request.user);
      current = new Parse.Role(request.object.id + "-mgr-current", propertyACL).save();
      propertyACL.setRoleWriteAccess(current);
      request.object.setACL(propertyACL);
      return request.object.save;
    }
  });

  Parse.Cloud.beforeSave("Unit", function(request, response) {
    request.object.set("user", request.user);
    return response.success();
  });

  Parse.Cloud.beforeSave("Lease", function(request, response) {
    request.object.set("user", request.user);
    return response.success();
  });

  Parse.Cloud.beforeSave("Task", function(request, response) {
    request.object.set("user", request.user);
    return response.success();
  });

  Parse.Cloud.beforeSave("Income", function(request, response) {
    request.object.set("user", request.user);
    return response.success();
  });

  Parse.Cloud.beforeSave("Expense", function(request, response) {
    request.object.set("user", request.user);
    return response.success();
  });

}).call(this);
