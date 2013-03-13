(function() {

  Parse.Cloud.beforeSave("Address", function(request, response) {
    if (!(request.object.get("thoroughfare") !== '' && request.object.get("locality") !== '' && request.object.get("administrative_area_level_1") !== '' && request.object.get("country") !== '' && request.object.get("postal_code") !== '')) {
      return response.error('insufficient_data');
    } else {
      return (new Parse.Query("Address")).withinKilometers("center", request.object.get("center"), 0).first().then(function(obj) {
        if (obj != null) {
          request.object.set("objectId", obj.get("objectId"));
          return (new Parse.Query("Property")).equalTo("user", request.user).equalTo("address", obj.get("objectId")).first().then(function(obj) {
            if (obj != null) {
              return response.error('taken_by_user');
            }
          });
        } else {
          return response.success();
        }
      });
    }
  });

  Parse.Cloud.beforeSave("Property", function(request, response) {
    request.object.set("user", request.user);
    if (request.object.get("title") == null) {
      return response.error('title_missing');
    }
    return response.success();
  });

  Parse.Cloud.beforeSave("Unit", function(request, response) {
    return request.object.set("user", request.user);
  });

  Parse.Cloud.beforeSave("Lease", function(request, response) {
    return request.object.set("user", request.user);
  });

  Parse.Cloud.beforeSave("Task", function(request, response) {
    return request.object.set("user", request.user);
  });

  Parse.Cloud.beforeSave("Income", function(request, response) {
    return request.object.set("user", request.user);
  });

  Parse.Cloud.beforeSave("Expense", function(request, response) {
    return request.object.set("user", request.user);
  });

}).call(this);
