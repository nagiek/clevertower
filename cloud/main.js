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
    propertyACL = existed ? request.object.getACL() : new Parse.ACL;
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
    if (!request.object.get("title")) {
      response.error('no_title');
    }
    if (!request.object.existed()) {
      return (new Parse.Query("Property")).get(property.objectId, {
        success: function(model) {
          request.object.set("user", request.user);
          request.object.setACL(model.getACL());
          console.log(model.getACL());
          return response.success();
        },
        error: function(model, error) {
          return response.error("bad_query");
        }
      });
    } else {
      return response.success();
    }
  });

  Parse.Cloud.beforeSave("Lease", function(request, response) {
    var end_date, moment, property, start_date;
    if (request.object.get("unit" === '')) {
      return response.error('title_missing');
    }
    moment = require('moment');
    start_date = request.object.get("start_date");
    end_date = request.object.get("end_date");
    if (start_date === '' || end_date === '') {
      return response.error('date_missing');
    }
    if (start_date > end_date) {
      return response.error('dates_incorrect');
    }
    if (moment(start_date) > moment(end_date)) {
      return response.error('dates_incorrect');
    }
    if (!request.object.existed()) {
      property = request.object.get("property");
      return (new Parse.Query("Property")).get(property.objectId, {
        success: function(model) {
          var modelACL;
          modelACL = model.getACL();
          request.object.set("user", request.user);
          request.object.set("confirmed", modelACL.getReadAccess(request.user));
          request.object.setACL(modelACL);
          return response.success();
        },
        error: function(model, error) {
          return response.error("bad_query");
        }
      });
    } else {
      return response.success();
    }
  });

  Parse.Cloud.afterSave("Lease", function(request) {
    var today, unit;
    today = new Date;
    if (start_date < today && today < end_date) {
      unit = request.object.get("unit");
      return (new Parse.Query("Property")).get(property.objectId, {
        success: function(model) {
          model.set("has_lease", true);
          model.set("active_lease", request.object.objectId);
          return model.save();
        }
      });
    }
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
