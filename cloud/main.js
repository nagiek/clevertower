(function() {

  Parse.Cloud.define("AddTenants", function(req, res) {
    var Mandrill, emails, propertyId, status, _;
    emails = req.params.emails;
    if (!emails) {
      return res.error;
    }
    propertyId = _ = require("underscore");
    Mandrill = require('mandrill');
    Mandrill.initialize('rE7-kYdcFOw7SxRfCfkVzQ');
    status = 'invited';
    return (new Parse.Query("Property")).include('mgrRole').get(req.params.propertyId, {
      success: function(property) {
        var mgrRole, notification, notificationACL, title;
        mgrRole = property.get("mgrRole");
        title = property.get("thoroughfare");
        notification = new Parse.Object("Notification");
        notificationACL = new Parse.ACL;
        return (new Parse.Query("Lease")).include('tntRole').get(req.params.leaseId, {
          success: function(lease) {
            var tenantACL, tenantRoleUsers, tntRole;
            tntRole = property.get("tntRole");
            if (tntRole && mgrRole) {
              tenantRoleUsers = tntRole.getUsers();
              tenantACL = new Parse.ACL;
              tenantACL.setRoleReadAccess(tntRole, true);
              tenantACL.setRoleReadAccess(mgrRole, true);
              tenantACL.setRoleWriteAccess(mgrRole, true);
            }
            return (new Parse.Query("_User")).containedIn("username", emails).find().then(function(users) {
              var newUsersSignUps;
              newUsersSignUps = [];
              _.each(emails, function(email) {
                var found_user, newUser, password, possible, tenant, _i;
                found_user = false;
                found_user = _.find(users, function(user) {
                  if (email === user.get("email")) {
                    return user;
                  }
                });
                if (found_user) {
                  tenant = new Parse.Object("Tenant");
                  tenant.save({
                    lease: lease,
                    status: status,
                    user: found_user,
                    accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
                    ACL: tenantACL
                  });
                  notificationACL.setReadAccess(found_user, true);
                  if (tntRole) {
                    return tenantRoleUsers.add(found_user);
                  }
                } else {
                  Mandrill.sendEmail({
                    message: {
                      subject: "Using Cloud Code and Mandrill is great!",
                      text: "Hello World!",
                      from_email: "parse@cloudcode.com",
                      from_name: "Cloud Code",
                      to: [
                        {
                          email: email,
                          name: email
                        }
                      ]
                    },
                    async: true
                  }, {
                    success: function(httpres) {},
                    error: function(httpres) {}
                  });
                  password = "";
                  possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
                  for (_i = 1; _i < 8; _i++) {
                    password += possible.charAt(Math.floor(Math.random() * possible.length));
                  }
                  newUser = new Parse.User({
                    username: email,
                    password: password,
                    email: email,
                    ACL: new Parse.ACL()
                  });
                  return newUsersSignUps.push(newUser.signUp());
                }
              });
              if (newUsersSignUps.length > 0) {
                Parse.Promise.when(newUsersSignUps).then(function() {
                  _.each(arguments, function(user) {
                    var tenant;
                    tenant = new Parse.Object("Tenant");
                    tenant.save({
                      lease: lease,
                      status: status,
                      user: user,
                      accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
                      ACL: tenantACL
                    });
                    return notificationACL.setReadAccess(user, true);
                  });
                  notification.setACL(notificationACL);
                  notification.save({
                    text: "You have been invited to join " + title,
                    channels: ["leases-" + req.params.leaseId],
                    name: "lease_invitation",
                    user: req.user,
                    property: req.object.get("property")
                  });
                  if (tntRole) {
                    return tenantRoleUsers.add(user);
                  }
                }, function(error) {
                  return res.error('signup_error');
                });
              } else {
                notification.setACL(notificationACL);
                notification.save({
                  text: "You have been invited to join " + title,
                  channels: ["leases-" + req.params.leaseId],
                  name: "lease_invitation",
                  user: req.user,
                  property: req.object.get("property")
                });
              }
              if (tntRole) {
                tntRole.save();
              }
              return res.success();
            });
          }
        }, function() {
          return res.error("bad_query");
        });
      },
      error: function() {
        return res.error("bad_query");
      }
    });
  });

  Parse.Cloud.define("CheckForUniqueProperty", function(req, res) {
    return (new Parse.Query("Property")).equalTo("user", req.user).withinKilometers("center", req.params.center, 0.001).first().then(function(obj) {
      if (obj) {
        return res.error("" + obj.id + ":taken_by_user");
      } else {
        return res.success();
      }
    }, function() {
      return res.error('bad_query');
    });
  });

  Parse.Cloud.beforeSave("_User", function(req, res) {
    var email;
    req.object.set("createdBy", req.user);
    email = req.object.get("email");
    if (email === '') {
      return res.error('missing_username');
    }
    if (!/^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_.-])+\.([a-zA-Z])+([a-zA-Z])+/.test(email)) {
      return res.error('invalid_email');
    }
    return res.success();
  });

  Parse.Cloud.beforeSave("Property", function(req, res) {
    var current, existed, isPublic, possible, propertyACL, randomId, role, _i;
    if (!(+req.object.get("center") !== +Parse.GeoPoint())) {
      return res.error('invalid_address');
    } else if (!(req.object.get("thoroughfare") !== '' && req.object.get("locality") !== '' && req.object.get("administrative_area_level_1") !== '' && req.object.get("country") !== '' && req.object.get("postal_code") !== '')) {
      return res.error('insufficient_data');
    } else {
      if (!req.object.get("title")) {
        return res.error('title_missing');
      }
    }
    existed = req.object.existed();
    propertyACL = existed ? req.object.getACL() : new Parse.ACL;
    if (!existed) {
      req.object.set("user", req.user);
      randomId = "";
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
      for (_i = 1; _i < 16; _i++) {
        randomId += possible.charAt(Math.floor(Math.random() * possible.length));
      }
      current = "mgr-current-" + randomId;
      propertyACL.setRoleReadAccess(current, true);
      propertyACL.setRoleWriteAccess(current, true);
      role = new Parse.Role(current, propertyACL);
      role.getUsers().add(req.user);
      return role.save().then(function(savedRole) {
        req.object.set("mgrRole", savedRole);
        return res.success();
      });
    } else {
      isPublic = req.object.get("public");
      if (propertyACL.getPublicReadAccess() !== isPublic) {
        propertyACL.setPublicReadAccess(isPublic);
        req.object.setACL(propertyACL);
      }
      return res.success();
    }
  });

  Parse.Cloud.beforeSave("Unit", function(req, res) {
    var propertyId;
    if (!req.object.get("property")) {
      res.error('no_property');
    }
    if (!req.object.get("title")) {
      res.error('no_title');
    }
    propertyId = req.object.get("property").id;
    if (!req.object.existed()) {
      return (new Parse.Query("Property")).get(propertyId, {
        success: function(model) {
          req.object.set("user", req.user);
          req.object.setACL(model.getACL());
          return res.success();
        },
        error: function(model, error) {
          return res.error("bad_query");
        }
      });
    } else {
      return res.success();
    }
  });

  Parse.Cloud.beforeSave("Lease", function(req, res) {
    var end_date, start_date, unit_date_query;
    if (!req.object.get("unit")) {
      return res.error('unit_missing');
    }
    start_date = req.object.get("start_date");
    end_date = req.object.get("end_date");
    if (!(start_date && end_date)) {
      return res.error('date_missing');
    }
    if (start_date === end_date) {
      return res.error('date_missing');
    }
    if (start_date > end_date) {
      return res.error('dates_incorrect');
    }
    unit_date_query = (new Parse.Query("Lease")).equalTo("unit", req.object.get("unit"));
    if (req.object.existed()) {
      unit_date_query.notEqualTo("id", req.object.get("unit"));
    }
    return unit_date_query.find().then(function(objs) {
      var propertyId, _;
      _ = require('underscore');
      _.each(objs, function(obj) {
        var ed, sd;
        sd = obj.get("start_date");
        if (start_date <= sd && sd <= end_date) {
          return res.error("" + obj.id + ":overlapping_dates");
        }
        ed = obj.get("end_date");
        if (start_date <= ed && ed <= end_date) {
          return res.error("" + obj.id + ":overlapping_dates");
        }
      });
      if (req.object.existed()) {
        return res.success();
      }
      propertyId = req.object.get("property").id;
      return (new Parse.Query("Property")).include('mgrRole').get(propertyId, {
        success: function(property) {
          var mgrRole, users;
          mgrRole = property.get("mgrRole");
          if (mgrRole) {
            users = mgrRole.getUsers();
            return users.query().get(req.user.id, {
              success: function(obj) {
                var confirmed, current, existed, leaseACL, name, notification, notificationACL, possible, randomId, role, _i;
                confirmed = obj ? true : false;
                if (!confirmed) {
                  name = user.get("name");
                  notification = new Parse.Object("Notification");
                  notificationACL = new Parse.ACL;
                  notificationACL.setRoleReadAccess(role, true);
                  notification.setACL(notificationACL);
                  notification.save({
                    name: "lease_application",
                    text: "" + name + " wants to join your property.",
                    channels: ["properties-" + propertyId],
                    user: req.user,
                    property: req.object.get("property")
                  });
                }
                req.object.set({
                  user: req.user,
                  confirmed: confirmed
                });
                existed = req.object.existed();
                leaseACL = existed ? req.object.getACL() : new Parse.ACL;
                if (!existed) {
                  randomId = "";
                  possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
                  for (_i = 1; _i < 16; _i++) {
                    randomId += possible.charAt(Math.floor(Math.random() * possible.length));
                  }
                  current = "tnt-current-" + randomId;
                  leaseACL.setRoleReadAccess(current, true);
                  leaseACL.setRoleWriteAccess(current, !confirmed);
                  leaseACL.setRoleWriteAccess(mgrRole, true);
                  leaseACL.setRoleReadAccess(mgrRole, true);
                  req.object.setACL(leaseACL);
                  role = new Parse.Role(current, leaseACL);
                  role.getUsers().add(req.user);
                  return role.save().then(function(savedRole) {
                    req.object.set("tntRole", savedRole);
                    return res.success();
                  }, function() {
                    return res.success();
                  });
                } else {
                  if (confirmed === leaseACL.getRoleWriteAccess(current)) {
                    leaseACL.setRoleWriteAccess(current, !confirmed);
                    role.setACL(leaseACL);
                    role.save();
                    req.object.setACL(leaseACL);
                    return res.success();
                  } else {
                    return res.success();
                  }
                }
              },
              error: function() {
                return res.error("user_missing");
              }
            });
          } else {
            return res.error("role_missing");
          }
        },
        error: function() {
          return res.error("bad_query");
        }
      });
    }, function() {
      return res.error("bad_query");
    });
  });

  Parse.Cloud.afterSave("Lease", function(req) {
    var end_date, propertyId, start_date, today;
    today = new Date;
    start_date = req.object.get("start_date");
    end_date = req.object.get("end_date");
    if (start_date < today && today < end_date) {
      (new Parse.Query("Unit")).get(req.object.get("unit").id, {
        success: function(model) {
          model.set("activeLease", req.object);
          return model.save();
        }
      });
    }
    propertyId = req.object.get("property").id;
    return (new Parse.Query("Property")).include('mgrRole').get(propertyId, {
      success: function(property) {
        var mgrRole, users;
        mgrRole = property.get("mgrRole");
        if (mgrRole) {
          users = mgrRole.getUsers();
          return users.query().get(req.user.id, {
            success: function(obj) {
              var emails;
              if (obj) {
                emails = req.object.get("emails");
                if (emails) {
                  return Parse.Cloud.run("AddTenants", {
                    propertyId: propertyId,
                    leaseId: req.object.id,
                    emails: emails
                  }, {
                    success: function(res) {},
                    error: function(res) {}
                  });
                }
              } else {
                emails = req.object.get("emails") || [];
                emails.push(req.user.get("email"));
                req.object.set(emails);
                return Parse.Cloud.run("AddTenants", {
                  propertyId: propertyId,
                  leaseId: req.object.id,
                  emails: emails
                }, {
                  success: function(res) {},
                  error: function(res) {}
                });
              }
            }
          });
        }
      }
    });
  });

  Parse.Cloud.beforeSave("Tenant", function(req, res) {
    if (req.object.get("accessToken") === "AZeRP2WAmbuyFY8tSWx8azlPEb") {
      req.object.unset("accessToken");
      return res.success();
    }
    return (new Parse.Query("Lease")).include('tntRole').get(req.object.get("lease").id, {
      success: function(lease) {
        var propertyId, status, tntRole, user;
        propertyId = lease.get("property").id;
        user = req.object.get("User");
        status = req.object.get("status");
        tntRole = property.get("tntRole");
        return (new Parse.Query("Property")).include('mgrRole').get(propertyId, {
          success: function(property) {
            var mgrRole, tenantACL, users;
            mgrRole = property.get("mgrRole");
            if (!req.object.existed()) {
              tenantACL = new Parse.ACL;
              if (tntRole) {
                tenantACL.setRoleReadAccess(tntRole, true);
              }
              if (mgrRole) {
                tenantACL.setRoleReadAccess(mgrRole, true);
              }
              if (mgrRole) {
                tenantACL.setRoleWriteAccess(mgrRole, true);
              }
              req.object.setACL(tenantACL);
            }
            if (mgrRole) {
              users = mgrRole.getUsers();
              return users.query().equalTo("user", user).first().then(function(obj) {
                var name, notification, notificationACL, tenantRole, title;
                if (obj) {
                  tenantRole = lease.get("tntRole");
                  tenantRole.getUsers().add(req.object.get("user"));
                  tenantRole.save();
                  title = property.get("thoroughfare");
                  notification = new Parse.Object("Notification");
                  notificationACL = new Parse.ACL;
                  notificationACL.setReadAccess(req.object.get("user"), true);
                  notification.setACL(notificationACL);
                  notification.save({
                    name: "lease_invitation",
                    text: "You have been invited to join " + title,
                    channels: ["leases-" + lease.id],
                    user: req.user,
                    property: property
                  });
                  status = status && status === 'pending' ? 'current' : 'invited';
                  req.object.set("status", status);
                  return res.success();
                } else {
                  name = user.get("name");
                  notification = new Parse.Object("Notification");
                  notificationACL = new Parse.ACL;
                  notificationACL.setRoleReadAccess(role, true);
                  notification.setACL(notificationACL);
                  notification.save({
                    name: "tenant_application",
                    text: "" + name + " wants to join your property.",
                    channels: ["property-" + propertyId],
                    user: req.user,
                    property: property
                  });
                  (new Parse.Query("_User")).get(user.id, {
                    success: function(user) {
                      var userACL;
                      userACL = user.getACL;
                      userACL.setRoleReadAccess(mgrRole, true);
                      return user.save({
                        ACL: userACL
                      });
                    }
                  });
                  status = status && status === 'invited' ? 'current' : 'pending';
                  req.object.set("status", status);
                  return res.success();
                }
              });
            } else {
              return res.error("no matching role");
            }
          },
          error: function() {
            return res.error("bad_query");
          }
        });
      },
      error: function() {
        return res.error("bad_query");
      }
    });
  });

  Parse.Cloud.afterSave("Notification", function(req) {
    var C, addedUrl, body, body_md5, channels, key, method, secret, serverUrl, signature, string_to_sign, text, timestamp, version;
    if (req.object.get("error")) {
      return;
    }
    C = require('cloud/lib/crypto.js');
    method = 'POST';
    serverUrl = 'http://api.pusherapp.com';
    addedUrl = "/apps/40364/events";
    version = '1.0';
    key = 'dee5c4022be4432d7152';
    secret = 'b38f0a4b567af901adcf';
    timestamp = Math.round(new Date().getTime() / 1000);
    text = req.object.get('text');
    body = {
      name: req.object.get('name'),
      data: JSON.stringify({
        text: text
      })
    };
    channels = req.object.get('channels');
    if (channels.length === 1) {
      body.channel = channels[0];
    } else {
      body.channels = channels;
    }
    body = JSON.stringify(body);
    body_md5 = C.CryptoJS.MD5(body).toString(C.CryptoJS.enc.Hex);
    string_to_sign = method + "\n" + addedUrl + "\n" + ("auth_key=" + key) + ("&auth_timestamp=" + timestamp) + ("&auth_version=" + version) + ("&body_md5=" + body_md5);
    signature = C.CryptoJS.HmacSHA256(string_to_sign, secret).toString(C.CryptoJS.enc.Hex);
    Parse.Cloud.httpreq({
      method: method,
      url: serverUrl + addedUrl,
      headers: {
        'Content-Type': 'application/json'
      },
      body: body,
      params: {
        auth_key: key,
        auth_timestamp: timestamp,
        auth_version: version,
        body_md5: body_md5,
        auth_signature: signature
      },
      success: function(httpres) {},
      error: function(error) {
        req.object.set("error", error.text);
        return req.object.save();
      }
    });
    return Parse.Push.send({
      channels: req.object.get("channels"),
      data: {
        alert: text
      }
    }, {
      error: function(error) {
        req.object.set("error", JSON.stringify(error));
        return req.object.save();
      }
    });
  });

  Parse.Cloud.beforeSave("Task", function(req, res) {
    req.object.set("user", req.user);
    return res.success();
  });

  Parse.Cloud.beforeSave("Income", function(req, res) {
    req.object.set("user", req.user);
    return res.success();
  });

  Parse.Cloud.beforeSave("Expense", function(req, res) {
    req.object.set("user", req.user);
    return res.success();
  });

}).call(this);
