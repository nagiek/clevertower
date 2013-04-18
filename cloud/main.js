(function() {

  Parse.Cloud.define("AddTenants", function(req, res) {
    var Mandrill, emails, status, _;
    emails = req.params.emails;
    if (!emails) {
      return res.error("emails_missing");
    }
    _ = require("underscore");
    Mandrill = require('mandrill');
    Mandrill.initialize('rE7-kYdcFOw7SxRfCfkVzQ');
    status = 'invited';
    return (new Parse.Query("Property")).include('network.role').get(req.params.propertyId, {
      success: function(property) {
        var mgrRole, network, title;
        network = property.get("network");
        mgrRole = network.get("role");
        title = property.get("thoroughfare");
        return (new Parse.Query("Lease")).include('role').get(req.params.leaseId, {
          success: function(lease) {
            var profileACL, tenantACL, tntRole, tntRoleUsers;
            tntRole = lease.get("role");
            tenantACL = new Parse.ACL;
            profileACL = new Parse.ACL;
            profileACL.setPublicReadAccess(true);
            profileACL.setPublicWriteAccess(true);
            if (tntRole) {
              tntRoleUsers = tntRole.getUsers();
              tenantACL.setRoleReadAccess(tntRole, true);
            }
            if (mgrRole) {
              tenantACL.setRoleReadAccess(mgrRole, true);
              tenantACL.setRoleWriteAccess(mgrRole, true);
            }
            return (new Parse.Query("Profile")).include("user").containedIn("email", emails).find().then(function(profiles) {
              var newProfileSaves;
              newProfileSaves = new Array();
              _.each(emails, function(email) {
                var found_profile, newProfile, notification, tenant, user;
                found_profile = false;
                found_profile = _.find(profiles, function(profile) {
                  if (email === profile.get("email")) {
                    return profile;
                  }
                });
                if (found_profile) {
                  tenant = new Parse.Object("Tenant");
                  notification = new Parse.Object("Notification");
                  user = found_profile.get("user");
                  if (user) {
                    notification.setACL(new Parse.ACL().setReadAccess(user, true));
                    if (tntRole) {
                      tntRoleUsers.add(found_profile.get("user"));
                    }
                  } else {
                    notification.setACL(new Parse.ACL());
                  }
                  tenant.save({
                    lease: lease,
                    property: property,
                    network: network,
                    status: status,
                    profile: found_profile,
                    accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
                    ACL: tenantACL
                  });
                  return notification.save({
                    text: "You have been invited to join " + title,
                    channels: ["profiles-" + found_profile.id],
                    channel: "profiles-" + found_profile.id,
                    name: "lease_invitation",
                    forMgr: false,
                    user: req.user,
                    property: property,
                    network: network,
                    ACL: new Parse.ACL().setReadAccess(found_profile.get("user"), true)
                  });
                } else {
                  newProfile = new Parse.Object("Profile");
                  return newProfileSaves.push(newProfile.save({
                    email: email,
                    ACL: profileACL
                  }));
                }
              });
              if (newProfileSaves.length > 0) {
                return Parse.Promise.when(newProfileSaves).then(function() {
                  _.each(arguments, function(profile) {
                    var tenant;
                    tenant = new Parse.Object("Tenant");
                    tenant.save({
                      lease: lease,
                      property: property,
                      network: network,
                      status: status,
                      profile: profile,
                      accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
                      ACL: tenantACL
                    });
                    new Parse.Object("Notification").save({
                      text: "You have been invited to join " + title,
                      channels: ["profiles-" + profile.id],
                      channel: "profiles-" + profile.id,
                      name: "lease_invitation",
                      user: req.user,
                      forMgr: false,
                      property: property,
                      network: network,
                      ACL: new Parse.ACL()
                    });
                    return Mandrill.sendEmail({
                      message: {
                        subject: "You have been invited to try CleverTower",
                        text: "Hello World!",
                        from_email: "parse@cloudcode.com",
                        from_name: "Cloud Code",
                        to: [
                          {
                            email: profile.get("email"),
                            name: profile.get("email")
                          }
                        ]
                      },
                      async: true
                    }, {
                      success: function(httpres) {},
                      error: function(httpres) {}
                    });
                  });
                  if (tntRole) {
                    tntRole.save();
                  }
                  return res.success(lease);
                }, function(error) {
                  return res.error('signup_error');
                });
              } else {
                if (tntRole) {
                  tntRole.save();
                }
                return res.success(lease);
              }
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

  Parse.Cloud.define("AddManagers", function(req, res) {
    var Mandrill, emails, status, _;
    emails = req.params.emails;
    if (!emails) {
      return res.error("emails_missing");
    }
    _ = require("underscore");
    Mandrill = require('mandrill');
    Mandrill.initialize('rE7-kYdcFOw7SxRfCfkVzQ');
    status = 'invited';
    (new Parse.Query("Network")).include('role').get(req.params.networkId, {
      success: function(network) {
        var managerACL, mgrRole, mgrRoleUsers, profileACL, title;
        mgrRole = network.get("role");
        managerACL = new Parse.ACL;
        title = network.get("title");
        profileACL = new Parse.ACL;
        profileACL.setPublicReadAccess(true);
        profileACL.setPublicWriteAccess(true);
        if (mgrRole) {
          managerACL.setRoleReadAccess(mgrRole, true);
          managerACL.setRoleWriteAccess(mgrRole, true);
          mgrRoleUsers = mgrRole.getUsers();
        }
        return (new Parse.Query("Profile")).include("user").containedIn("email", emails).find().then(function(profiles) {
          var newManagerSaves, newProfileSaves;
          newProfileSaves = new Array();
          newManagerSaves = new Array();
          _.each(emails, function(email) {
            var found_profile, manager, newProfile, notification, user;
            found_profile = false;
            found_profile = _.find(profiles, function(profile) {
              if (email === profile.get("email")) {
                return profile;
              }
            });
            if (found_profile) {
              manager = new Parse.Object("Manager");
              notification = new Parse.Object("Notification");
              user = found_profile.get("user");
              if (user) {
                notification.setACL(new Parse.ACL().setReadAccess(user, true));
                if (mgrRole) {
                  mgrRoleUsers.add(user);
                }
              } else {
                notification.setACL(new Parse.ACL());
              }
              newManagerSaves.push(manager.save({
                network: network,
                status: status,
                admin: false,
                profile: found_profile,
                accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
                ACL: managerACL
              }));
              return notification.save({
                text: "You have been invited to join " + title,
                channels: ["profiles-" + found_profile.id],
                channel: "profiles-" + found_profile.id,
                name: "network_invitation",
                forMgr: true,
                user: req.user,
                network: network
              });
            } else {
              newProfile = new Parse.Object("Profile");
              return newProfileSaves.push(newProfile.save({
                email: email,
                ACL: profileACL
              }));
            }
          });
          if (newProfileSaves.length > 0) {
            return Parse.Promise.when(newProfileSaves).then(function() {
              _.each(arguments, function(profile) {
                var manager;
                manager = new Parse.Object("Manager");
                newManagerSaves.push(manager.save({
                  network: network,
                  status: status,
                  admin: false,
                  profile: profile,
                  accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
                  ACL: managerACL
                }));
                console.log(manager);
                Mandrill.sendEmail({
                  message: {
                    subject: "You have been invited to try CleverTower",
                    text: "Hello World!",
                    from_email: "parse@cloudcode.com",
                    from_name: "Cloud Code",
                    to: [
                      {
                        email: profile.get("email"),
                        name: profile.get("email")
                      }
                    ]
                  },
                  async: true
                }, {
                  success: function(httpres) {},
                  error: function(httpres) {}
                });
                return new Parse.Object("Notification").save({
                  text: "You have been invited to join " + title,
                  channels: ["profiles-" + profile.id],
                  channel: "profiles-" + profile.id,
                  name: "network_invitation",
                  forMgr: true,
                  user: req.user,
                  network: network,
                  ACL: new Parse.ACL()
                });
              });
              if (mgrRole) {
                mgrRole.save();
              }
              return Parse.Promise.when(newManagerSaves).then(function() {
                _.each(arguments, function(obj) {
                  return delete obj.attributes.accessToken;
                });
                return res.success(arguments);
              });
            }, function(error) {
              return res.error('signup_error');
            });
          } else {
            if (mgrRole) {
              mgrRole.save();
            }
            return Parse.Promise.when(newManagerSaves).then(function() {
              _.each(arguments, function(obj) {
                return delete obj.attributes.accessToken;
              });
              return res.success(arguments);
            });
          }
        });
      }
    }, function() {
      return res.error("bad_query");
    });
    return {
      error: function() {
        return res.error("bad_query");
      }
    };
  });

  Parse.Cloud.define("CheckForUniqueProperty", function(req, res) {
    var network, networkAddressQuery, userAddressQuery;
    userAddressQuery = (new Parse.Query("Property")).equalTo("user", req.user).withinKilometers("center", req.params.center, 0.001).first();
    network = {
      id: req.params.networkId,
      __type: "Pointer",
      className: "_Role"
    };
    networkAddressQuery = (new Parse.Query("Property")).equalTo("network", network).withinKilometers("center", req.params.center, 0.001).first();
    return Parse.Promise.when(userAddressQuery, networkAddressQuery).then(function(obj1, obj2) {
      if (obj1) {
        return res.error("" + obj1.id + ":taken_by_user");
      }
      if (obj2) {
        return res.error("" + obj2.id + ":taken_by_network");
      }
      return res.success();
    }, function() {
      return res.error('bad_query');
    });
  });

  Parse.Cloud.beforeSave("Profile", function(req, res) {
    if (!req.object.existed()) {
      req.object.set("createdBy", req.user);
    }
    return res.success();
  });

  Parse.Cloud.afterSave("_User", function(req, res) {
    var email;
    if (req.object.existed()) {
      return;
    }
    email = req.object.get("email");
    return (new Parse.Query("Profile")).equalTo('email', email).first().then(function(profile) {
      var profileACL, _;
      profileACL = new Parse.ACL();
      profileACL.setPublicReadAccess(true);
      profileACL.setWriteAccess(req.object, true);
      if (!profile) {
        profile = new Parse.Object("Profile");
        return profile.save({
          email: email,
          ACL: profileACL,
          user: req.object
        });
      } else {
        _ = require("underscore");
        return (new Parse.Query("Manager")).include('network.role').equalTo('profile', profile).find().then(function(objs) {
          _.each(objs, function(obj) {
            var role;
            role = obj.get("network").get("role");
            if (role) {
              role.getUsers().add(req.obj);
              return role.save();
            }
          });
          return (new Parse.Query("Tenant")).include('lease.role').equalTo('profile', profile).find().then(function(objs) {
            return _.each(objs, function(obj) {
              var role;
              role = obj.get("lease").get("role");
              if (role) {
                role.getUsers().add(req.obj);
                role.save();
              }
              return (new Parse.Query("Notification")).equalTo('channel', "profiles-" + profile.id).find().then(function(objs) {
                _.each(objs, function(obj) {
                  role = obj.get("lease").get("role");
                  if (role) {
                    role.getUsers().add(req.obj);
                    return role.save();
                  }
                });
                return profile.save({
                  email: req.object.get("email"),
                  user: req.object
                }, ACL(profileACL));
              });
            });
          });
        });
      }
    });
  });

  Parse.Cloud.beforeSave("Network", function(req, res) {
    var name, query;
    name = req.object.get("name");
    if (!name) {
      return res.error('name_missing');
    }
    if (name === 'edit' || name === 'show' || name === 'new' || name === 'delete' || name === 'www') {
      return res.error('name_reserved');
    }
    if (!(name.length > 3)) {
      return res.error('name_too_short');
    }
    if (name.length > 31) {
      return res.error('name_too_long');
    }
    if (!/^[a-z]+$/.test(name)) {
      return res.error('name_invalid');
    }
    query = (new Parse.Query("Network")).equalTo('name', name);
    if (req.object.existed()) {
      query.notEqualTo('objectId', req.object.id);
    }
    return query.first().then(function(obj) {
      var current, networkACL, possible, randomId, role, _i;
      if (obj) {
        return res.error("" + obj.id + ":name_taken");
      }
      if (req.object.existed()) {
        return res.success();
      }
      networkACL = new Parse.ACL();
      randomId = "";
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
      for (_i = 1; _i < 16; _i++) {
        randomId += possible.charAt(Math.floor(Math.random() * possible.length));
      }
      current = "mgr-current-" + randomId;
      networkACL.setRoleReadAccess(current, true);
      networkACL.setRoleWriteAccess(current, true);
      req.object.setACL(networkACL);
      role = new Parse.Role(current, networkACL);
      role.getUsers().add(req.user);
      return role.save().then(function(savedRole) {
        req.object.set("role", savedRole);
        return res.success();
      }, function() {
        return res.error("role_error");
      });
    }, function() {
      return res.error("bad_query");
    });
  });

  Parse.Cloud.afterSave("Network", function(req, res) {
    if (!req.object.existed()) {
      return (new Parse.Query("Profile")).equalTo('user', req.user).first().then(function(profile) {
        return (new Parse.Query("_Role")).get(req.object.get("role").id, {
          success: function(role) {
            var manager, managerACL;
            manager = new Parse.Object("Manager");
            managerACL = new Parse.ACL;
            managerACL.setRoleReadAccess(role, true);
            managerACL.setRoleWriteAccess(role, true);
            manager.save({
              network: req.object,
              status: 'accepted',
              admin: true,
              profile: profile,
              accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
              ACL: managerACL
            });
            return req.user.save({
              network: req.object
            });
          }
        });
      });
    }
  });

  Parse.Cloud.beforeSave("Property", function(req, res) {
    var isPublic, network, propertyACL, query;
    if (!(+req.object.get("center") !== +Parse.GeoPoint())) {
      return res.error('invalid_address');
    } else if (req.object.get("thoroughfare") === '' || req.object.get("locality") === '' || req.object.get("administrative_area_level_1") === '' || req.object.get("country") === '' || req.object.get("postal_code") === '') {
      return res.error('insufficient_data');
    } else {
      if (!req.object.get("title")) {
        return res.error('title_missing');
      }
    }
    if (!req.object.existed()) {
      network = req.user.get("network");
      req.object.set({
        user: req.user,
        network: network
      });
      return query = (new Parse.Query("Network")).get(network.id, {
        success: function(obj) {
          req.object.setACL(obj.getACL());
          return res.success();
        },
        error: function() {
          return res.error('bad_query');
        }
      });
    } else {
      isPublic = req.object.get("public");
      propertyACL = req.object.getACL();
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
      return (new Parse.Query("Property")).include('network.role').get(propertyId, {
        success: function(property) {
          var mgrRole, network, users;
          network = property.get("network");
          mgrRole = network.get("role");
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
                    channels: ["networks-" + network.id, "properties-" + propertyId],
                    channel: "networks-" + network.id,
                    forMgr: true,
                    user: req.user,
                    property: req.object.get("property"),
                    network: network
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
    return (new Parse.Query("Property")).include('network.role').get(propertyId, {
      success: function(property) {
        var mgrRole, users;
        mgrRole = property.get("network").get("role");
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
    return (new Parse.Query("Lease")).include('role').get(req.object.get("lease").id, {
      success: function(lease) {
        var profile, propertyId, status, tntRole, user;
        propertyId = lease.get("property").id;
        profile = req.object.get("profile");
        user = profile.get("user");
        status = req.object.get("status");
        tntRole = lease.get("role");
        return (new Parse.Query("Property")).include('network.role').get(propertyId, {
          success: function(property) {
            var mgrRole, network, tenantACL, users;
            network = property.get("network");
            mgrRole = network.get("role");
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
              req.object.set({
                network: network,
                ACL: tenantACL
              });
            }
            if (mgrRole) {
              users = mgrRole.getUsers();
              return users.query().get(req.user.id, {
                success: function(obj) {
                  var name, notification, notificationACL, tenantRole, title;
                  if (obj) {
                    tenantRole = lease.get("tntRole");
                    tenantRole.getUsers().add(user);
                    tenantRole.save();
                    title = property.get("thoroughfare");
                    notification = new Parse.Object("Notification");
                    notificationACL = new Parse.ACL;
                    notificationACL.setReadAccess(req.object.get("user"), true);
                    notification.setACL(notificationACL);
                    notification.save({
                      name: "lease_invitation",
                      text: "You have been invited to join " + title,
                      channels: ["profiles-" + profile.id],
                      channel: "profiles-" + profile.id,
                      forMgr: false,
                      user: req.user,
                      property: property,
                      network: network
                    });
                    status = status && status === 'pending' ? 'current' : 'invited';
                    req.object.set("status", status);
                    return res.success();
                  } else {
                    name = user.get("name");
                    notification = new Parse.Object("Notification");
                    notificationACL = new Parse.ACL;
                    notificationACL.setRoleReadAccess(mgrRole, true);
                    notification.setACL(notificationACL);
                    notification.save({
                      name: "tenant_application",
                      text: "" + name + " wants to join your property.",
                      channels: ["networks-" + network.id, "properties-" + propertyId],
                      channel: "networks-" + network.id,
                      forMgr: true,
                      user: req.user,
                      property: property,
                      network: network
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
                },
                error: function() {
                  return res.error("bad_query");
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

  Parse.Cloud.beforeSave("Manager", function(req, res) {
    if (req.object.get("accessToken") === "AZeRP2WAmbuyFY8tSWx8azlPEb") {
      req.object.unset("accessToken");
      return res.success();
    }
    return (new Parse.Query("Network")).include('role').get(req.object.get("network").id, {
      success: function(network) {
        var managerACL, mgrRole, profile, status, user, users;
        profile = req.object.get("profile");
        user = profile.get("user");
        status = req.object.get("status");
        mgrRole = network.get("role");
        if (!req.object.existed()) {
          managerACL = new Parse.ACL;
          if (mgrRole) {
            managerACL.setRoleReadAccess(mgrRole, true);
          }
          if (mgrRole) {
            managerACL.setRoleWriteAccess(mgrRole, true);
          }
          req.object.setACL(managerACL);
        }
        if (mgrRole) {
          users = mgrRole.getUsers();
          return users.query().get(req.user.id, {
            success: function(obj) {
              var name, notification, notificationACL, title;
              if (obj) {
                users.add(user);
                mgrRole.save();
                title = network.get("title");
                notification = new Parse.Object("Notification");
                notificationACL = new Parse.ACL;
                notificationACL.setReadAccess(req.object.get("user"), true);
                notification.setACL(notificationACL);
                notification.save({
                  name: "network_invitation",
                  text: "You have been invited to join " + title,
                  channels: ["networks-" + network.id],
                  channel: "networks-" + network.id,
                  forMgr: false,
                  user: req.user,
                  network: network
                });
                status = status && status === 'pending' ? 'current' : 'invited';
                req.object.set("status", status);
                return res.success();
              } else {
                name = user.get("name");
                notification = new Parse.Object("Notification");
                notificationACL = new Parse.ACL;
                notificationACL.setRoleReadAccess(mgrRole, true);
                notification.setACL(notificationACL);
                notification.save({
                  name: "network_application",
                  text: "" + name + " wants to join your property.",
                  channels: ["networks-" + network.id, "properties-" + req.params.propertyId],
                  channel: "networks-" + network.id,
                  forMgr: true,
                  user: req.user,
                  network: network
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
            },
            error: function() {
              return res.error("bad_query");
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
  });

  Parse.Cloud.afterSave("Notification", function(req) {
    var C, Mandrill, addedUrl, body, body_md5, channels, key, method, secret, serverUrl, signature, string_to_sign, text, timestamp, version;
    Mandrill = require('mandrill');
    Mandrill.initialize('rE7-kYdcFOw7SxRfCfkVzQ');
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
    Parse.Cloud.httpRequest({
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
      channels: channels,
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
