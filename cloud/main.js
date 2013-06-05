(function() {
  Parse.Cloud.define("AddTenants", function(req, res) {
    var Mandrill, className, emails, status, _;

    emails = req.params.emails;
    className = req.params.className;
    if (!emails) {
      return res.error("emails_missing");
    }
    _ = require("underscore");
    Mandrill = require('mandrill');
    Mandrill.initialize('rE7-kYdcFOw7SxRfCfkVzQ');
    status = 'invited';
    Parse.Cloud.useMasterKey();
    return (new Parse.Query(className)).include('role').include("property.role").include("property.mgrRole").include("property.network.role").get(req.params.objectId, {
      success: function(leaseOrInquiry) {
        var mgrQuery, mgrRole, mgrUsers, netQuery, netRole, netUsers, network, profileQuery, propRole, property, title, tntRole;

        tntRole = leaseOrInquiry.get("role");
        property = leaseOrInquiry.get("property");
        propRole = property.get("role");
        mgrRole = property.get("mgrRole");
        title = property.get("thoroughfare");
        network = property.get("network");
        netRole = network ? network.get("role") : false;
        if (mgrRole || netRole) {
          if (mgrRole) {
            mgrUsers = mgrRole.getUsers();
            mgrQuery = mgrUsers.query().equalTo("objectId", req.user.id).first();
          }
          if (netRole) {
            netUsers = netRole.getUsers();
            netQuery = netUsers.query().equalTo("objectId", req.user.id).first();
          }
        }
        profileQuery = (new Parse.Query("Profile")).include("user").containedIn("email", emails).find();
        return Parse.Promise.when(mgrQuery, netQuery, profileQuery).then(function(mgrObj, netObj, profiles) {
          var email, foundProfile, joinClassACL, joinClassName, newProfileSaves, profileACL, propRoleUsers, tntRoleUsers, _i, _len;

          if (className === "Lease" && !(mgrObj || netObj)) {
            res.error("not_a_manager");
          }
          joinClassName = className === "Lease" ? "Tenant" : "Applicant";
          joinClassACL = new Parse.ACL;
          if (tntRole) {
            tntRoleUsers = tntRole.getUsers();
            joinClassACL.setRoleReadAccess(tntRole, true);
            joinClassACL.setRoleWriteAccess(tntRole, true);
          }
          if (netRole) {
            joinClassACL.setRoleReadAccess(netRole, true);
            joinClassACL.setRoleWriteAccess(netRole, true);
          }
          if (propRole && className === "Lease") {
            propRoleUsers = propRole.getUsers();
            joinClassACL.setRoleReadAccess(propRole, true);
          }
          if (mgrRole) {
            joinClassACL.setRoleReadAccess(mgrRole, true);
            joinClassACL.setRoleWriteAccess(mgrRole, true);
          }
          profileACL = new Parse.ACL;
          profileACL.setPublicReadAccess(true);
          profileACL.setPublicWriteAccess(true);
          newProfileSaves = new Array();
          for (_i = 0, _len = emails.length; _i < _len; _i++) {
            email = emails[_i];
            foundProfile = false;
            foundProfile = _.find(profiles, function(profile) {
              if (email === profile.get("email")) {
                return profile;
              }
            });
            if (foundProfile) {
              newProfileSaves.push(foundProfile);
            } else {
              newProfileSaves.push(new Parse.Object("Profile").save({
                email: email,
                ACL: profileACL
              }));
            }
          }
          return Parse.Promise.when(newProfileSaves).then(function() {
            var joinClassSaves;

            joinClassSaves = new Array();
            _.each(arguments, function(profile) {
              var user, vars;

              user = profile.get("user");
              vars = {
                property: property,
                network: network,
                unit: leaseOrInquiry.get("unit"),
                listing: leaseOrInquiry.get("listing"),
                status: user && user.id === req.user.id ? 'current' : status,
                profile: profile,
                accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
                ACL: joinClassACL
              };
              vars[className.toLowerCase()] = leaseOrInquiry;
              return joinClassSaves.push(new Parse.Object(joinClassName).save(vars));
            });
            return Parse.Promise.when(joinClassSaves);
          }, function() {
            return res.error('profiles_not_saved');
          }).then(function() {
            var notifClassSaves;

            notifClassSaves = new Array();
            _.each(arguments, function(joinClass) {
              var notifVars, notificationACL, profile, user;

              profile = joinClass.get("profile");
              user = profile.get("user");
              if (!(user && user.id === req.user.id)) {
                notificationACL = new Parse.ACL();
                if (user) {
                  notificationACL.setReadAccess(user, true);
                  notificationACL.setWriteAccess(user, true);
                  if (tntRole) {
                    tntRoleUsers.add(user);
                  }
                  if (propRole && className === "Lease") {
                    propRoleUsers.add(user);
                  }
                } else {
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
                    success: function(httpres) {
                      return {
                        error: function(httpres) {}
                      };
                    }
                  });
                }
                notifVars = {
                  text: "You have been invited to join " + title,
                  channels: ["profiles-" + profile.id],
                  channel: "profiles-" + profile.id,
                  name: ("" + className + "_invitation").toLowerCase(),
                  forMgr: false,
                  withAction: true,
                  profile: req.user.get("profile"),
                  email: email,
                  property: property,
                  network: network,
                  ACL: notificationACL
                };
                notifVars[joinClassName.toLowerCase()] = joinClass;
                return notifClassSaves.push(new Parse.Object("Notification").save(notifVars));
              }
            });
            return Parse.Promise.when(notifClassSaves);
          }, function() {
            return res.error('joinClasses_not_saved');
          }).then(function() {
            var roleSaves;

            roleSaves = [];
            if (propRole && className === "Lease") {
              roleSaves.push(propRole.save());
            }
            if (tntRole) {
              roleSaves.push(tntRole.save());
            }
            return Parse.Promise.when(roleSaves);
          }, function(error) {
            return res.error('signup_error');
          }).then(function() {
            return res.success(leaseOrInquiry);
          }, function(error) {
            return res.error('role_save_error');
          });
        }, function(error) {
          return res.error('role_query_error');
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
    Parse.Cloud.useMasterKey();
    status = 'invited';
    return (new Parse.Query("Network")).include('vstRole').get(req.params.networkId, {
      success: function(network) {
        var joinClassACL, joinClassName, joinClasses, title, vstRole, vstRoleUsers;

        vstRole = network.get("vstRole");
        title = network.get("title");
        joinClassName = "Manager";
        joinClassACL = network.getACL();
        joinClassACL.setRoleWriteAccess(vstRole, true);
        joinClasses = void 0;
        vstRoleUsers = vstRole.getUsers();
        Parse.Cloud.useMasterKey();
        (new Parse.Query("Profile")).include("user").containedIn("email", emails).find().then(function(profiles) {
          var email, foundProfile, newProfileSaves, profileACL, _i, _len;

          profileACL = new Parse.ACL;
          profileACL.setPublicReadAccess(true);
          profileACL.setPublicWriteAccess(true);
          newProfileSaves = new Array();
          for (_i = 0, _len = emails.length; _i < _len; _i++) {
            email = emails[_i];
            foundProfile = false;
            foundProfile = _.find(profiles, function(profile) {
              if (email === profile.get("email")) {
                return profile;
              }
            });
            if (foundProfile) {
              newProfileSaves.push(foundProfile);
            } else {
              newProfileSaves.push(new Parse.Object("Profile").save({
                email: email,
                ACL: profileACL
              }));
            }
          }
          return Parse.Promise.when(newProfileSaves).then(function() {
            var joinClassSaves;

            joinClassSaves = new Array();
            _.each(arguments, function(profile) {
              var user, vars;

              user = profile.get("user");
              vars = {
                network: network,
                status: user && user.id === req.user.id ? 'current' : status,
                profile: profile,
                accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
                ACL: joinClassACL
              };
              return joinClassSaves.push(new Parse.Object(joinClassName).save(vars));
            });
            return Parse.Promise.when(joinClassSaves);
          }, function() {
            return res.error('profiles_not_saved');
          }).then(function() {
            var joinClass, notifClassSaves, notifVars, notificationACL, profile, user, _j, _len1;

            joinClasses = arguments;
            notifClassSaves = new Array();
            for (_j = 0, _len1 = joinClasses.length; _j < _len1; _j++) {
              joinClass = joinClasses[_j];
              profile = joinClass.get("profile");
              user = profile.get("user");
              if (!(user && user.id === req.user.id)) {
                notificationACL = new Parse.ACL();
                if (user) {
                  notificationACL.setReadAccess(user, true);
                  notificationACL.setWriteAccess(user, true);
                  vstRoleUsers.add(user);
                } else {
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
                    success: function(httpres) {
                      return {
                        error: function(httpres) {}
                      };
                    }
                  });
                }
                notifVars = {
                  text: "You have been invited to join " + title,
                  channels: ["profiles-" + profile.id],
                  channel: "profiles-" + profile.id,
                  name: "network_invitation",
                  forMgr: false,
                  withAction: true,
                  profile: req.user.get("profile"),
                  email: email,
                  network: network,
                  manager: joinClass,
                  ACL: notificationACL
                };
                notifClassSaves.push(new Parse.Object("Notification").save(notifVars));
              }
            }
            return Parse.Promise.when(notifClassSaves);
          }, function() {
            return res.error('joinClasses_not_saved');
          }).then(function() {
            return vstRole.save();
          }, function(error) {
            return res.error('signup_error');
          }).then(function() {
            return res.success(joinClasses);
          }, function(error) {
            return res.error('signup_error');
          });
        });
        return {
          error: function() {
            return res.error("bad_query");
          }
        };
      },
      error: function() {
        return res.error("bad_query");
      }
    });
  });

  Parse.Cloud.define("AddPhotoActivity", function(req, res) {
    return (new Parse.Query("Property")).get(req.params.propertyId, {
      success: function(property) {
        var Activity, activity, activityACL;

        Activity = Parse.Object.extend("Activity");
        activity = new Activity;
        activityACL = new Parse.ACL;
        activityACL.setPublicReadAccess(true);
        return activity.save({
          activity_type: "new_photo",
          "public": true,
          photoUrl: req.params.photoUrl,
          center: property.get("center"),
          property: property,
          network: property.get("network"),
          ACL: activityACL
        }, {
          success: function() {
            return res.success(activity);
          },
          error: function() {
            return res.error("bad_save");
          }
        });
      },
      error: function() {
        return res.error("bad_query");
      }
    });
  });

  Parse.Cloud.beforeSave("Profile", function(req, res) {
    if (!req.object.existed()) {
      req.object.set("createdBy", req.user);
    }
    return res.success();
  });

  Parse.Cloud.beforeSave("_User", function(req, res) {
    var email;

    if (req.object.existed()) {
      return res.success();
    }
    email = req.object.get("email");
    return (new Parse.Query("Profile")).equalTo('email', email).first().then(function(profile) {
      if (profile) {
        req.object.set("profile", profile);
        return res.success();
      } else {
        profile = new Parse.Object("Profile");
        return profile.save().then(function() {
          req.object.set("profile", profile);
          return res.success();
        });
      }
    }, function() {
      return res.error("no_profile");
    });
  });

  Parse.Cloud.afterSave("_User", function(req, res) {
    if (req.object.existed() || !req.object.get("profile")) {
      return;
    }
    return (new Parse.Query("Profile")).get(req.object.get("profile").id, {
      success: function(profile) {
        var managerQuery, notifQuery, profileACL, tenantQuery;

        if (!profile.get("user")) {
          profileACL = new Parse.ACL();
          profileACL.setPublicReadAccess(true);
          profileACL.setReadAccess(req.object, true);
          profileACL.setWriteAccess(req.object, true);
          profile.save({
            email: req.object.get("email"),
            user: req.object,
            ACL: profileACL
          });
        }
        Parse.Cloud.useMasterKey();
        managerQuery = (new Parse.Query("Manager")).include('network.role').equalTo('profile', profile).find();
        tenantQuery = (new Parse.Query("Tenant")).include('property.role').include('lease.role').equalTo('profile', profile).find();
        notifQuery = (new Parse.Query("Notification")).equalTo('channel', "profiles-" + profile.id).find();
        return Parse.Promise.when(managerQuery, tenantQuery, notifQuery).then(function(managers, tenants, notifs) {
          var manager, notif, notifACL, propRole, tenant, tntRole, vstRole, _i, _j, _k, _len, _len1, _len2, _results;

          if (managers) {
            for (_i = 0, _len = managers.length; _i < _len; _i++) {
              manager = managers[_i];
              vstRole = manager.get("network").get("vstRole");
              if (vstRole) {
                vstRole.getUsers().add(req.object);
                vstRole.save();
              }
            }
          }
          if (tenants) {
            for (_j = 0, _len1 = tenants.length; _j < _len1; _j++) {
              tenant = tenants[_j];
              tntRole = tenant.get("lease").get("role");
              propRole = tenant.get("property").get("role");
              if (tntRole) {
                tntRole.getUsers().add(req.object);
                tntRole.save();
              }
              if (propRole) {
                propRole.getUsers().add(req.object);
                propRole.save();
              }
            }
          }
          if (notifs) {
            _results = [];
            for (_k = 0, _len2 = notifs.length; _k < _len2; _k++) {
              notif = notifs[_k];
              notifACL = notif.getACL();
              notifACL.setReadAccess(req.object, true);
              notifACL.setWriteAccess(req.object, true);
              _results.push(notif.save({
                ACL: notifACL
              }));
            }
            return _results;
          }
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
      var current, networkACL, possible, randomId, role, visit, vstRole, _i;

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
      visit = "mgr-possible-" + randomId;
      networkACL.setRoleReadAccess(current, true);
      networkACL.setRoleWriteAccess(current, true);
      networkACL.setRoleReadAccess(visit, true);
      req.object.setACL(networkACL);
      role = new Parse.Role(current, networkACL);
      vstRole = new Parse.Role(visit, networkACL);
      role.getUsers().add(req.user);
      return Parse.Promise.when(role.save(), vstRole.save()).then(function() {
        req.object.set("role", role);
        req.object.set("vstRole", vstRole);
        return res.success();
      }, function() {
        return res.error("role_error");
      });
    }, function() {
      return res.error("bad_query");
    });
  });

  Parse.Cloud.afterSave("Network", function(req, res) {
    var managerACL;

    if (!req.object.existed()) {
      managerACL = req.object.getACL();
      managerACL.setPublicReadAccess(false);
      new Parse.Object("Manager").save({
        network: req.object,
        status: 'current',
        admin: true,
        profile: req.user.get("profile"),
        accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
        ACL: managerACL
      });
      return req.user.save({
        network: req.object
      });
    }
  });

  Parse.Cloud.beforeSave("Property", function(req, res) {
    var current, isPublic, mgr, mgrRole, possible, propertyACL, randomId, role, roleACL, _i;

    if (!req.object.get("center")) {
      return res.error('invalid_address');
    } else if (req.object.get("thoroughfare") === '' || req.object.get("locality") === '' || req.object.get("administrative_area_level_1") === '' || req.object.get("country") === '' || req.object.get("postal_code") === '') {
      return res.error('insufficient_data');
    } else if (!req.object.get("title")) {
      return res.error('title_missing');
    }
    if (!req.object.existed()) {
      if (req.user.get("network")) {
        return (new Parse.Query("Network")).include("role").get(req.user.get("network").id, {
          success: function(network) {
            var current, mgr, mgrRole, netRole, possible, randomId, role, roleACL, _i;

            netRole = network.get("role");
            randomId = "";
            possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            for (_i = 1; _i < 16; _i++) {
              randomId += possible.charAt(Math.floor(Math.random() * possible.length));
            }
            current = "prop-current-" + randomId;
            mgr = "prop-mgr-" + randomId;
            roleACL = network.getACL();
            roleACL.setRoleReadAccess(current, true);
            roleACL.setRoleWriteAccess(mgr, true);
            roleACL.setRoleReadAccess(mgr, true);
            if (netRole) {
              roleACL.setRoleWriteAccess(netRole, true);
              roleACL.setRoleReadAccess(netRole, true);
            }
            role = new Parse.Role(current, roleACL);
            mgrRole = new Parse.Role(mgr, roleACL);
            return Parse.Promise.when(role.save(), mgrRole.save()).then(function() {
              var propertyACL;

              propertyACL = roleACL;
              propertyACL.setPublicReadAccess(true);
              req.object.set({
                "public": true,
                user: req.user,
                role: role,
                mgrRole: mgrRole,
                network: network,
                ACL: propertyACL
              });
              return res.success();
            }, function() {
              return res.error("role_error");
            });
          },
          error: function() {
            return res.error('bad_query');
          }
        });
      } else {
        randomId = "";
        possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        for (_i = 1; _i < 16; _i++) {
          randomId += possible.charAt(Math.floor(Math.random() * possible.length));
        }
        current = "prop-current-" + randomId;
        mgr = "prop-mgr-" + randomId;
        roleACL = new Parse.ACL;
        roleACL.setRoleReadAccess(current, true);
        roleACL.setRoleWriteAccess(mgr, true);
        roleACL.setRoleReadAccess(mgr, true);
        role = new Parse.Role(current, roleACL);
        mgrRole = new Parse.Role(mgr, roleACL);
        role.getUsers().add(req.user);
        mgrRole.getUsers().add(req.user);
        return Parse.Promise.when(role.save(), mgrRole.save()).then(function() {
          var propertyACL;

          propertyACL = roleACL;
          propertyACL.setPublicReadAccess(true);
          req.object.set({
            "public": true,
            user: req.user,
            role: role,
            mgrRole: mgrRole,
            ACL: propertyACL
          });
          return res.success();
        }, function() {
          return res.error("role_error");
        });
      }
    } else {
      isPublic = req.object.get("public");
      propertyACL = req.object.getACL();
      if (propertyACL.getPublicReadAccess() !== isPublic) {
        propertyACL.setPublicReadAccess(isPublic);
        req.object.setACL(propertyACL);
        return (new Parse.Query("Listing")).equalTo('property', req.object).find().then(function(objs) {
          var l, listingACL, listingsToSave, _j, _len;

          if (objs) {
            listingsToSave = new Array;
            for (_j = 0, _len = objs.length; _j < _len; _j++) {
              l = objs[_j];
              if (l.get("public" !== isPublic)) {
                listingACL = l.getACL();
                listingACL.setPublicReadAccess(isPublic);
                l.set({
                  "public": isPublic,
                  ACL: listingACL
                });
                listingsToSave.push(l);
              }
            }
            if (listingsToSave.length > 0) {
              Parse.Object.saveAll(listingsToSave);
            }
            return res.success();
          } else {
            return res.success();
          }
        }, function() {
          return res.error("bad_query");
        });
      } else {
        return res.success();
      }
    }
  });

  Parse.Cloud.afterSave("Property", function(req) {
    if (!req.object.existed() && req.object.get("public")) {
      return (new Parse.Query("Profile")).equalTo('user', req.user).first().then(function(profile) {
        var activity, activityACL;

        activity = new Parse.Object("Activity");
        activityACL = new Parse.ACL;
        activityACL.setPublicReadAccess(true);
        return activity.save({
          activity_type: "new_property",
          "public": true,
          center: req.object.get("center"),
          property: req.object,
          network: req.object.get("network"),
          title: req.object.get("title"),
          profile: profile,
          ACL: activityACL
        });
      });
    }
  });

  Parse.Cloud.beforeSave("Unit", function(req, res) {
    if (!req.object.get("property")) {
      return res.error('no_property');
    }
    if (!req.object.get("title")) {
      return res.error('no_title');
    }
    if (!req.object.existed()) {
      return (new Parse.Query("Property")).get(req.object.get("property").id, {
        success: function(property) {
          var propertyACL;

          propertyACL = property.getACL();
          if (!(property.get("network") && property.get("network") === req.user.get("network"))) {
            propertyACL.setReadAccess(req.user.id, true);
            propertyACL.setWriteAccess(req.user.id, true);
          }
          req.object.set({
            user: req.user,
            property: property,
            ACL: propertyACL
          });
          return res.success();
        },
        error: function() {
          return res.error("bad_query");
        }
      });
    } else {
      return res.success();
    }
  });

  Parse.Cloud.beforeSave("Inquiry", function(req, res) {
    var end_date, existed, listing, start_date;

    existed = req.object.existed();
    start_date = req.object.get("start_date");
    end_date = req.object.get("end_date");
    listing = req.object.get("listing");
    if (!(start_date && end_date)) {
      return res.error('date_missing');
    }
    if (start_date === end_date) {
      return res.error('date_missing');
    }
    if (start_date > end_date) {
      return res.error('dates_incorrect');
    }
    if (!listing) {
      return res.error('listing_missing');
    }
    if (existed) {
      return res.success();
    }
    return (new Parse.Query("Listing")).include('network.role').get(listing.id, {
      success: function(obj) {
        var emails, leaseACL, name, network, notification, notificationACL, property, role;

        property = obj.get("property");
        network = obj.get("network");
        role = network.get("role");
        emails = req.object.get("emails") || [];
        emails.push(req.user.get("email"));
        req.object.set({
          user: req.user,
          emails: emails,
          listing: obj,
          unit: obj.get("unit"),
          property: property,
          network: network
        });
        name = req.user.get("name");
        notification = new Parse.Object("Notification");
        notificationACL = new Parse.ACL();
        notificationACL.setRoleReadAccess(role, true);
        notificationACL.setRoleWriteAccess(role, true);
        notificationACL.setWriteAccess(req.user, true);
        notification.save({
          name: "new_inquiry",
          text: "" + name + " wants to join your property.",
          channels: ["networks-" + network.id, "properties-" + property.id],
          channel: "networks-" + network.id,
          forMgr: true,
          property: property,
          profile: req.user.get("profile"),
          network: network,
          ACL: notificationACL
        });
        leaseACL = new Parse.ACL;
        leaseACL.setReadAccess(req.user.id, true);
        leaseACL.setWriteAccess(req.user.id, true);
        leaseACL.setRoleWriteAccess(role, true);
        leaseACL.setRoleReadAccess(role, true);
        req.object.setACL(leaseACL);
        return res.success();
      },
      error: function() {
        return res.error("bad_query");
      }
    });
  });

  Parse.Cloud.afterSave("Inquiry", function(req) {
    return Parse.Cloud.run("AddTenants", {
      objectId: req.object.id,
      emails: req.object.get("emails"),
      className: "Inquiry"
    }, {
      success: function(res) {},
      error: function(res) {}
    });
  });

  Parse.Cloud.beforeSave("Lease", function(req, res) {
    var end_date, existed, start_date, unit_date_query;

    existed = req.object.existed();
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
    if (existed) {
      unit_date_query.notEqualTo("id", req.object.get("unit"));
    }
    return unit_date_query.find().then(function(objs) {
      var ed, obj, sd, _i, _len;

      if (objs) {
        for (_i = 0, _len = objs.length; _i < _len; _i++) {
          obj = objs[_i];
          sd = obj.get("start_date");
          if (start_date <= sd && sd <= end_date) {
            return res.error("" + obj.id + ":overlapping_dates");
          }
          ed = obj.get("end_date");
          if (start_date <= ed && ed <= end_date) {
            return res.error("" + obj.id + ":overlapping_dates");
          }
        }
      }
      if (existed) {
        return res.success();
      }
      return (new Parse.Query("Property")).include('mgrRole').include('network.role').get(req.object.get("property").id, {
        success: function(property) {
          var current, emails, leaseACL, mgrRole, netRole, network, possible, randomId, role, users, _j;

          network = property.get("network");
          mgrRole = property.get("mgrRole");
          req.object.set({
            user: req.user,
            confirmed: false,
            property: property,
            network: network
          });
          if (network) {
            netRole = network.get("role");
            if (!netRole) {
              return res.error("role_missing");
            }
            users = netRole.getUsers();
            return users.query().get(req.user.id, {
              success: function(obj) {
                var current, emails, leaseACL, possible, randomId, role, _j;

                if (obj) {
                  req.object.set("confirmed", true);
                } else {
                  emails = req.object.get("emails") || [];
                  emails.push(req.user.getEmail());
                  req.object.set("emails", emails);
                }
                randomId = "";
                possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
                for (_j = 1; _j < 16; _j++) {
                  randomId += possible.charAt(Math.floor(Math.random() * possible.length));
                }
                current = "tnt-current-" + randomId;
                leaseACL = property.getACL();
                leaseACL.setPublicReadAccess(false);
                leaseACL.setRoleReadAccess(current, true);
                if (netRole) {
                  leaseACL.setRoleWriteAccess(netRole, true);
                }
                if (netRole) {
                  leaseACL.setRoleReadAccess(netRole, true);
                }
                leaseACL.setRoleReadAccess(mgrRole, true);
                leaseACL.setRoleWriteAccess(mgrRole, true);
                req.object.setACL(leaseACL);
                role = new Parse.Role(current, leaseACL);
                return role.save().then(function() {
                  req.object.set("role", role);
                  return res.success();
                }, function() {
                  return res.error();
                });
              },
              error: function() {
                return res.error("user_missing");
              }
            });
          } else {
            emails = req.object.get("emails") || [];
            emails.push(req.user.getEmail());
            req.object.set("emails", emails);
            randomId = "";
            possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            for (_j = 1; _j < 16; _j++) {
              randomId += possible.charAt(Math.floor(Math.random() * possible.length));
            }
            current = "tnt-current-" + randomId;
            leaseACL = property.getACL();
            leaseACL.setPublicReadAccess(false);
            leaseACL.setRoleReadAccess(current, true);
            if (netRole) {
              leaseACL.setRoleWriteAccess(netRole, true);
            }
            if (netRole) {
              leaseACL.setRoleReadAccess(netRole, true);
            }
            leaseACL.setRoleReadAccess(mgrRole, true);
            leaseACL.setRoleWriteAccess(mgrRole, true);
            req.object.setACL(leaseACL);
            role = new Parse.Role(current, leaseACL);
            role.getUsers().add(req.user);
            return role.save().then(function() {
              req.object.set("role", role);
              return res.success();
            }, function() {
              return res.error();
            });
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
    var active, end_date, start_date, today;

    today = new Date;
    start_date = req.object.get("start_date");
    end_date = req.object.get("end_date");
    active = start_date < today && today < end_date;
    if (active || !req.object.existed()) {
      (new Parse.Query("Unit")).get(req.object.get("unit").id, {
        success: function(unit) {
          var noProperty;

          if (active) {
            unit.set("activeLease", req.object);
          }
          noProperty = !unit.get("property");
          if (noProperty) {
            unit.set({
              ACL: req.object.getACL(),
              property: req.object.get("property")
            });
          }
          if (active || noProperty) {
            return unit.save();
          }
        }
      });
    }
    if (req.object.get("emails")) {
      return Parse.Cloud.run("AddTenants", {
        objectId: req.object.id,
        emails: req.object.get("emails"),
        className: "Lease"
      });
    }
  });

  Parse.Cloud.beforeSave("Listing", function(req, res) {
    var end_date, start_date;

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
    if (!req.object.get("title")) {
      return res.error('title_missing');
    }
    if (!req.object.get("rent")) {
      return res.error('rent_missing');
    }
    return (new Parse.Query("Unit")).include('property.network.role').get(req.object.get("unit").id, {
      success: function(unit) {
        var isPublic, listingACL, netRole, network, property, propertyIsPublic;

        property = unit.get("property");
        propertyIsPublic = property.getACL().getPublicReadAccess();
        if (!req.object.existed()) {
          network = property.get("network");
          netRole = network.get("role");
          listingACL = new Parse.ACL();
          listingACL.setPublicReadAccess(propertyIsPublic);
          listingACL.setRoleWriteAccess(netRole, true);
          listingACL.setRoleReadAccess(netRole, true);
          req.object.set({
            locality: property.get("locality"),
            center: property.get("center"),
            bedrooms: unit.get("bedrooms"),
            bathrooms: unit.get("bathrooms"),
            square_feet: unit.get("square_feet"),
            user: req.user,
            "public": propertyIsPublic,
            ACL: listingACL
          });
          return res.success();
        } else {
          isPublic = req.object.get("public");
          if (propertyIsPublic === false && isPublic === true) {
            listingACL = req.object.getACL();
            listingACL.setPublicReadAccess(false);
            req.object.set({
              "public": false,
              ACL: listingACL
            });
          }
          return res.success();
        }
      }
    });
  });

  Parse.Cloud.afterSave("Listing", function(req) {
    if (!req.object.existed() && req.object.get("public")) {
      return (new Parse.Query("Profile")).equalTo('user', req.user).first().then(function(profile) {
        var activity, activityACL;

        activity = new Parse.Object("Activity");
        activityACL = new Parse.ACL;
        activityACL.setPublicReadAccess(true);
        return activity.save({
          activity_type: "new_listing",
          "public": true,
          rent: req.object.get("rent"),
          center: req.object.get("center"),
          listing: req.object,
          unit: req.object.get("unit"),
          property: req.object.get("property"),
          network: req.object.get("network"),
          title: req.object.get("title"),
          profile: profile,
          ACL: activityACL
        });
      });
    }
  });

  Parse.Cloud.beforeSave("Tenant", function(req, res) {
    if (req.object.get("accessToken") === "AZeRP2WAmbuyFY8tSWx8azlPEb") {
      req.object.unset("accessToken");
      return res.success();
    }
    Parse.Cloud.useMasterKey();
    return (new Parse.Query("Lease")).include('role').include("property.mgrRole").include("property.role").include("property.network.role").get(req.object.get("lease").id, {
      success: function(lease) {
        var mgrQuery, mgrRole, mgrUsers, netQuery, netRole, netUsers, network, newStatus, profileQuery, propRole, property, status, tenantACL, tntRole;

        property = lease.get("property");
        status = req.object.get("status");
        newStatus = req.object.get("newStatus");
        tntRole = lease.get("role");
        propRole = property.get("role");
        mgrRole = property.get("mgrRole");
        network = property.get("network");
        if (network) {
          netRole = network.get("role");
        }
        if (!req.object.existed()) {
          tenantACL = new Parse.ACL;
          if (propRole) {
            tenantACL.setRoleReadAccess(propRole, true);
          }
          if (tntRole) {
            tenantACL.setRoleReadAccess(tntRole, true);
            tenantACL.setRoleWriteAccess(tntRole, true);
          }
          if (mgrRole) {
            tenantACL.setRoleReadAccess(mgrRole, true);
            tenantACL.setRoleWriteAccess(mgrRole, true);
          }
          if (netRole) {
            tenantACL.setRoleReadAccess(netRole, true);
            tenantACL.setRoleWriteAccess(netRole, true);
          }
          req.object.set({
            property: property,
            network: network,
            unit: lease.get("unit"),
            lease: lease,
            ACL: tenantACL
          });
        }
        if (mgrRole || netRole) {
          if (mgrRole) {
            mgrUsers = mgrRole.getUsers();
            mgrQuery = mgrUsers.query().equalTo("objectId", req.user.id).first();
          }
          if (netRole) {
            netUsers = netRole.getUsers();
            netQuery = netUsers.query().equalTo("objectId", req.user.id).first();
          }
          profileQuery = (new Parse.Query("Profile")).include("user").equalTo("objectId", req.object.get("profile").id).first();
          return Parse.Promise.when(mgrQuery, netQuery, profileQuery).then(function(mgrObj, netObj, profile) {
            var activity, activityACL, notification, notificationACL, profileACL, savesToComplete, title, user;

            savesToComplete = [];
            user = profile.get("user");
            if (mgrObj || netObj) {
              if (user) {
                if (tntRole) {
                  tntRole.getUsers().add(user);
                  savesToComplete.push(tntRole.save());
                }
                if (propRole) {
                  propRole.getUsers().add(user);
                  savesToComplete.push(propRole.save());
                }
              }
              if (req.object.existed() && status && status === 'pending' && newStatus && newStatus === 'current') {
                if (user) {
                  savesToComplete.push(user.save({
                    property: property,
                    unit: req.object.get("unit"),
                    lease: req.object.get("lease")
                  }));
                }
                activity = new Parse.Object("Activity");
                activityACL = new Parse.ACL;
                if (netRole) {
                  activityACL.setRoleReadAccess(netRole, true);
                }
                if (mgrRole) {
                  activityACL.setRoleReadAccess(mgrRole, true);
                }
                if (propRole) {
                  activityACL.setRoleReadAccess(propRole, true);
                }
                savesToComplete.push(activity.save({
                  activity_type: "new_tenant",
                  "public": false,
                  center: property.get("center"),
                  unit: req.object.get("unit"),
                  property: property,
                  network: network,
                  profile: profile,
                  ACL: activityACL
                }));
              } else {
                newStatus = 'invited';
                title = property.get("thoroughfare");
                notificationACL = new Parse.ACL;
                notificationACL.setReadAccess(user, true);
                notificationACL.setWriteAccess(user, true);
                savesToComplete.push(new Parse.Object("Notification").save({
                  name: "lease_invitation",
                  text: "You have been invited to join " + title,
                  channels: ["profiles-" + profile.id],
                  channel: "profiles-" + profile.id,
                  forMgr: false,
                  withAction: true,
                  property: property,
                  network: network,
                  ACL: notificationACL
                }));
              }
              req.object.set("status", newStatus);
            } else {
              if (mgrRole || netRole) {
                profileACL = profile.getACL();
                if (mgrRole) {
                  profileACL.setRoleReadAccess(mgrRole, true);
                }
                if (netRole) {
                  profileACL.setRoleReadAccess(netRole, true);
                }
                savesToComplete.push(profile.save({
                  ACL: profileACL
                }));
              }
              if (req.object.existed() && status && status === 'invited' && newStatus && newStatus === 'current') {
                if (user) {
                  savesToComplete.push(user.save({
                    property: property,
                    unit: req.object.get("unit"),
                    lease: req.object.get("lease")
                  }));
                }
                activity = new Parse.Object("Activity");
                activityACL = new Parse.ACL;
                if (mgrRole) {
                  activityACL.setRoleReadAccess(mgrRole, true);
                }
                if (netRole) {
                  activityACL.setRoleReadAccess(netRole, true);
                }
                if (propRole) {
                  activityACL.setRoleReadAccess(propRole, true);
                }
                savesToComplete.push(activity.save({
                  activity_type: "new_tenant",
                  "public": false,
                  center: property.get("center"),
                  unit: lease.get("unit"),
                  property: property,
                  network: network,
                  profile: profile,
                  ACL: activityACL
                }));
              } else {
                newStatus = 'pending';
                notification = new Parse.Object("Notification");
                notificationACL = new Parse.ACL;
                if (mgrRole) {
                  notificationACL.setRoleReadAccess(mgrRole, true);
                  notificationACL.setRoleWriteAccess(mgrRole, true);
                }
                if (netRole) {
                  notificationACL.setRoleReadAccess(netRole, true);
                  notificationACL.setRoleWriteAccess(netRole, true);
                }
                savesToComplete.push(notification.save({
                  name: "tenant_inquiry",
                  text: "%NAME wants to join your property.",
                  channels: ["networks-" + network.id, "properties-" + propertyId],
                  channel: "networks-" + network.id,
                  forMgr: true,
                  withAction: true,
                  profile: profile,
                  property: property,
                  network: network,
                  ACL: notificationACL
                }));
              }
              req.object.set("status", newStatus);
            }
            return Parse.Promise.when(savesToComplete);
          }, function() {
            return res.error("bad_query");
          }).then(function() {
            return res.success();
          }, function() {
            return res.error("bad_save");
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

  Parse.Cloud.beforeSave("Manager", function(req, res) {
    if (req.object.get("accessToken") === "AZeRP2WAmbuyFY8tSWx8azlPEb") {
      req.object.unset("accessToken");
      return res.success();
    }
    Parse.Cloud.useMasterKey();
    return (new Parse.Query("Network")).include('role').include('vstRole').get(req.object.get("network").id, {
      success: function(network) {
        var managerACL, netQuery, netRole, netUsers, newStatus, profileQuery, status, vstRole;

        status = req.object.get("status");
        newStatus = req.object.get("newStatus");
        netRole = network.get("role");
        vstRole = network.get("vstRole");
        if (!req.object.existed()) {
          managerACL = network.getACL();
          managerACL.setRoleWriteAccess(vstRole, true);
          req.object.setACL(managerACL);
        }
        netUsers = netRole.getUsers();
        netQuery = netUsers.query().equalTo("objectId", req.user.id).first();
        profileQuery = (new Parse.Query("Profile")).include("user").equalTo("objectId", req.object.get("profile").id).first();
        return Parse.Promise.when(netQuery, profileQuery).then(function(netObj, profile) {
          var notification, notificationACL, profileACL, savesToComplete, title, user;

          savesToComplete = [];
          user = profile.get("user");
          if (netObj) {
            if (req.object.existed() && status && status === 'pending' && newStatus && newStatus === 'current') {
              if (user) {
                savesToComplete.push(user.save("network", network));
                netRole.getUsers().add(user);
                savesToComplete.push(netRole.save());
              }
            } else {
              newStatus = 'invited';
              title = network.get("title");
              notificationACL = new Parse.ACL;
              notificationACL.setReadAccess(user, true);
              notificationACL.setWriteAccess(user, true);
              savesToComplete.push(new Parse.Object("Notification").save({
                name: "network_invitation",
                text: "You have been invited to join " + title,
                channels: ["profiles-" + profile.id],
                channel: "profiles-" + profile.id,
                forMgr: false,
                withAction: true,
                profile: req.user.get("profile"),
                network: network,
                ACL: notificationACL
              }));
            }
            req.object.set("status", newStatus);
          } else {
            profileACL = profile.getACL();
            profileACL.setRoleReadAccess(netRole, true);
            savesToComplete.push(profile.save({
              ACL: profileACL
            }));
            if (req.object.existed() && status && status === 'invited' && newStatus && newStatus === 'current') {
              if (user) {
                savesToComplete.push(user.save("network", network));
                netRole.getUsers().add(user);
                savesToComplete.push(netRole.save());
              }
            } else {
              newStatus = 'pending';
              notification = new Parse.Object("Notification");
              notificationACL = new Parse.ACL;
              notificationACL.setRoleReadAccess(netRole, true);
              notificationACL.setRoleWriteAccess(netRole, true);
              savesToComplete.push(notification.save({
                name: "manager_inquiry",
                text: "%NAME wants to join your network.",
                channels: ["networks-" + network.id],
                channel: "networks-" + network.id,
                forMgr: true,
                withAction: true,
                profile: profile,
                network: network,
                ACL: notificationACL
              }));
            }
            req.object.set("status", newStatus);
          }
          return Parse.Promise.when(savesToComplete);
        }, function() {
          return res.error("bad_query");
        }).then(function() {
          return res.success();
        }, function() {
          return res.error("bad_save");
        });
      },
      error: function() {
        return res.error("bad_query");
      }
    });
  });

  Parse.Cloud.afterSave("Notification", function(req) {
    var C, Mandrill, addedUrl, body, body_md5, channels, key, method, name, profile, push_text, secret, serverUrl, signature, string_to_sign, text, timestamp, version;

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
    if (!channels || channels.length === 1) {
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
    push_text = text.indexOf("%NAME") > 0 ? (profile = req.object.get("profile"), name = profile.get("first_name") ? profile.get("first_name") : profile.get("email"), text.replace("%NAME", name)) : text;
    return Parse.Push.send({
      channels: channels,
      data: {
        alert: push_text
      }
    }, {
      error: function(error) {
        req.object.set("error", JSON.stringify(error));
        return req.object.save();
      }
    });
  });

  Parse.Cloud.beforeSave("Search", function(req, res) {
    req.object.set({
      user: req.user,
      ACL: new Parse.ACL()
    });
    return res.success();
  });

  Parse.Cloud.beforeSave("Post", function(req, res) {
    if (!req.object.existed()) {
      return res.success();
    }
    return (new Parse.Query("Profile")).equalTo("user", req.user).first().then(function(profile) {
      var isPublic, postACL;

      req.object.set("profile", profile);
      isPublic = req.object.get("post_type" === "building") ? false : true;
      postACL = new Parse.ACL;
      postACL.setReadAccess(req.user, true);
      postACL.setWriteAccess(req.user, true);
      if (req.object.get("property")) {
        return (new Parse.Query("Property")).include("network").get(req.object.get("property").id, {
          success: function(property) {
            var mgrRole, netRole, network, propRole;

            network = property.get("network");
            req.object.set("center", property.get("center"));
            if (isPublic) {
              postACL.setPublicReadAccess(true);
            } else {
              propRole = property.get("role");
              mgrRole = property.get("mgrRole");
              if (propRole) {
                postACL.setRoleReadAccess(propRole, true);
              }
              if (mgrRole) {
                postACL.setRoleReadAccess(mgrRole, true);
              }
              if (network) {
                netRole = network.get("role");
                if (netRole) {
                  postACL.setRoleReadAccess(netRole, true);
                }
              }
            }
            req.object.set("ACL", postACL);
            return res.success(req.object);
          },
          error: function() {
            return res.error("bad_query");
          }
        });
      } else {
        if (isPublic) {
          postACL.setPublicReadAccess(true);
          req.object.set("ACL", postACL);
        }
        return res.success();
      }
    }, function() {
      return res.error("bad_query");
    });
  });

  Parse.Cloud.afterSave("Post", function(req, res) {
    if (!req.object.existed()) {
      return (new Parse.Query("Profile")).equalTo("user", req.user).first().then(function(profile) {
        var activity, activityACL;

        if (req.object.get("property")) {
          return (new Parse.Query("Property")).include('role').include('network.role').get(req.object.get("property").id, {
            success: function(property) {
              var activity, activityACL, mgrRole, netRole, network, propRole;

              propRole = property.get("role");
              mgrRole = property.get("mgrRole");
              network = property.get("network");
              activity = new Parse.Object("Activity");
              activityACL = new Parse.ACL;
              if (propRole) {
                activityACL.setRoleReadAccess(propRole, true);
              }
              if (mgrRole) {
                activityACL.setRoleReadAccess(mgrRole, true);
              }
              if (network) {
                netRole = network.get("role");
                if (netRole) {
                  activityACL.setRoleReadAccess(netRole, true);
                }
              }
              activityACL.setReadAccess(req.user, true);
              if (req.object.get("public")) {
                activityACL.setPublicReadAccess(true);
              }
              return activity.save({
                activity_type: "new_post",
                post_type: req.object.get("post_type"),
                title: req.object.get("title"),
                body: req.object.get("body"),
                "public": req.object.get("public"),
                center: property.get("center"),
                property: property,
                network: property.get("network"),
                profile: profile,
                lease: req.user.get("lease"),
                unit: req.user.get("unit"),
                post: req.object,
                ACL: activityACL
              });
            }
          });
        } else {
          activity = new Parse.Object("Activity");
          activityACL = new Parse.ACL;
          activityACL.setPublicReadAccess(true);
          return activity.save({
            activity_type: "new_post",
            post_type: req.object.get("post_type"),
            title: req.object.get("title"),
            body: req.object.get("body"),
            "public": true,
            center: req.object.get("center"),
            profile: profile,
            post: req.object,
            ACL: activityACL
          });
        }
      });
    }
  });

}).call(this);
