(function() {

  Parse.Cloud.define("CheckForUniqueProperty", function(request, response) {
    return (new Parse.Query("Property")).equalTo("user", request.user).withinKilometers("center", request.params.center, 0.001).first({
      success: function(obj) {
        if (obj) {
          return response.error("" + obj.id + ":taken_by_user");
        } else {
          return response.success();
        }
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
    var current, existed, isPublic, propertyACL, role, saveFlag;
    saveFlag = false;
    existed = request.object.existed();
    propertyACL = existed ? request.object.get("ACL") : new Parse.ACL;
    if (!existed) {
      saveFlag = true;
      current = request.object.id + "-mgr-current";
      propertyACL.setRoleReadAccess(current, true);
      propertyACL.setRoleWriteAccess(current, true);
      role = new Parse.Role(current, propertyACL);
      role.getUsers().add(request.user);
      role.save();
    } else {
      isPublic = request.object.get("public");
      if (propertyACL.getPublicReadAccess() !== isPublic) {
        saveFlag = true;
        propertyACL.setPublicReadAccess(isPublic);
      }
    }
    if (saveFlag) {
      request.object.setACL(propertyACL);
      return request.object.save();
    }
  });

  Parse.Cloud.beforeSave("Unit", function(request, response) {
    var property;
    property = request.object.get("property");
    if (!property) {
      response.error('no_property');
    }
    request.object.set("user", request.user);
    request.object.setACL(property.get("ACL"));
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
