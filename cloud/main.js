(function() {

  Parse.Cloud.define("CheckForUniqueProperty", function(request, response) {
    return (new Parse.Query("Property")).equalTo("user", request.user).withinKilometers("center", request.params.center, 0.001).first().then(function(obj) {
      if (obj) {
        return response.error("" + obj.id + ":taken_by_user");
      } else {
        return response.success();
      }
    }, function() {
      return response.error('bad_query');
    });
  });

  Parse.Cloud.beforeSave("_User", function(request, response) {
    var email;
    request.object.set("createdBy", request.user);
    email = request.object.get("email");
    if (email === '') {
      return response.error('missing_username');
    }
    if (!/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test(email)) {
      return response.error('invalid_email');
    }
    return response.success();
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
    var end_date, start_date, unit_date_query;
    if (!request.object.get("unit")) {
      return response.error('unit_missing');
    }
    start_date = request.object.get("start_date");
    end_date = request.object.get("end_date");
    if (!(start_date && end_date)) {
      return response.error('date_missing');
    }
    if (start_date === end_date) {
      return response.error('date_missing');
    }
    if (start_date > end_date) {
      return response.error('dates_incorrect');
    }
    unit_date_query = (new Parse.Query("Lease")).equalTo("unit", request.object.get("unit"));
    if (request.object.existed()) {
      unit_date_query.notEqualTo("id", request.object.get("unit"));
    }
    return unit_date_query.find().then(function(objs) {
      var property, _;
      _ = require('underscore');
      _.each(objs, function(obj) {
        var ed, sd;
        sd = obj.get("start_date");
        if (start_date < sd && sd < end_date) {
          return response.error("" + obj.id + ":overlapping_dates");
        }
        ed = obj.get("end_date");
        if (start_date < ed && ed < end_date) {
          return response.error("" + obj.id + ":overlapping_dates");
        }
      });
      if (request.object.existed()) {
        return response.success();
      }
      property = request.object.get("property");
      return (new Parse.Query("Property")).get(property.objectId, {
        success: function(model) {
          var modelACL;
          modelACL = model.getACL();
          request.object.set({
            user: request.user,
            confirmed: modelACL.getReadAccess(request.user)
          });
          request.object.setACL(modelACL);
          return response.success();
        },
        error: function(model, error) {
          return response.error("bad_query");
        }
      });
    });
  });

  Parse.Cloud.afterSave("Lease", function(request) {
    var emails, end_date, propertyId, start_date, today;
    today = new Date;
    start_date = request.object.get("start_date");
    end_date = request.object.get("end_date");
    if (start_date < today && today < end_date) {
      (new Parse.Query("Unit")).get(request.object.get("unit").objectId, {
        success: function(model) {
          model.set("has_lease", true);
          model.set("activeLease", request.object);
          return model.save();
        }
      });
    }
    emails = request.object.get("emails");
    if (emails) {
      propertyId = request.object.get("property").objectId;
      return (new Parse.Query("Role")).equalTo("name", "" + propertyId + "-mgr-current").first().then(function(property) {
        var status, _;
        _ = require("underscore");
        status = 'invited';
        return _.each(emails, function(email) {
          return (new Parse.Query("_User")).equalTo("username", email).first().then(function(user) {
            var password, possible, tenant, _i;
            if (user) {
              tenant = new Parse.Object("Tenant");
              return tenant.save({
                lease: request.object,
                status: status,
                user: user,
                bypassToken: "AZeRP2WAmb"
              });
            } else {
              password = "";
              possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
              for (_i = 1; _i < 8; _i++) {
                password += possible.charAt(Math.floor(Math.random() * possible.length));
              }
              return Parse.User.signUp(email, password, {
                email: email,
                ACL: new Parse.ACL()
              }, {
                success: function(user) {
                  tenant = new Parse.Object("Tenant");
                  return tenant.save({
                    lease: request.object,
                    status: status,
                    user: user,
                    bypassToken: "AZeRP2WAmb"
                  });
                }
              });
            }
          });
        });
      });
    }
  });

  Parse.Cloud.beforeSave("Tenant", function(request, response) {
    if (request.object.existed() || request.object.get("bypassToken") === "AZeRP2WAmb") {
      return response.success();
    }
    return (new Parse.Query("Lease")).get(request.object.get("lease").objectId, {
      success: function(lease) {
        var propertyId;
        propertyId = lease.get("property").objectId;
        return (new Parse.Query("Role")).equalTo("name", "" + propertyId + "-mgr-current").first().then(function(role) {
          var users;
          if (role) {
            users = role.getUsers();
            return users.query().equalTo("user", request.object.get("User")).first().then(function(obj) {
              var status;
              if (obj) {
                status = 'invited';
                request.object.set("status", status);
                return response.success();
              } else {
                status = 'pending';
                request.object.set("status", status);
                return response.success();
              }
            });
          } else {
            return response.error("no matching role");
          }
        }, function() {
          return response.error("bad_query");
        });
      }
    });
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
