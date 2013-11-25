(function() {
  Parse.Cloud.define("PromoteToFeatured", function(req, res) {
    Parse.Cloud.useMasterKey();
    return (new Parse.Query("Listing")).equalTo('objectId', req.params.objectId).first().then(function(obj) {
      var attrs;

      if (obj) {
        attrs = {
          cover: obj.get("image_profile"),
          property: obj.get("property"),
          rent: obj.get("rent"),
          locality: obj.get("locality"),
          title: obj.get("title")
        };
        return new Parse.Object("FeaturedListing").save(attrs).then(function() {
          return res.success();
        });
      } else {
        return res.error("bad_query");
      }
    }, function() {
      return res.error("bad_query");
    });
  });

  Parse.Cloud.define("SetPicture", function(req, res) {
    return Parse.Cloud.httpRequest({
      method: "GET",
      url: req.params.url,
      success: function(httpres) {
        var Buffer, buf, file;

        Buffer = require('buffer').Buffer;
        buf = new Buffer(httpres.buffer);
        file = new Parse.File(req.user.getUsername() + "-picture.jpeg", {
          base64: buf.toString('base64')
        });
        return file.save().then(function() {
          console.log('1a');
          return (new Parse.Query("Profile")).equalTo('objectId', req.user.get("profile").id).first();
        }, function(error) {
          console.log('1b');
          return res.error(error);
        }).then(function(profile) {
          console.log('2a');
          return profile.save({
            image_thumb: file.url(),
            image_profile: file.url(),
            image_full: file.url()
          });
        }, function(error) {
          console.log('2b');
          return res.error(error);
        }).then(function() {
          console.log('3a');
          return res.success(file.url());
        }, function(error) {
          console.log('3b');
          return res.error(error);
        });
      },
      error: function(error) {
        return res.error(error);
      }
    });
  });

  Parse.Cloud.define("AddTenants", function(req, res) {
    var Mandrill, className, emails, existingProfiles, status, _;

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
    existingProfiles = [];
    return (new Parse.Query(className)).include('role').include("property.role").include("property.mgrRole").include("property.network.role").equalTo("objectId", req.params.objectId).first().then(function(leaseOrInquiry) {
      var joinClassACL, joinClassName, mgrQuery, mgrRole, mgrUsers, netQuery, netRole, netUsers, network, profileQuery, propRole, property, title, tntRole;

      tntRole = leaseOrInquiry.get("role");
      property = leaseOrInquiry.get("property");
      propRole = property.get("role");
      mgrRole = property.get("mgrRole");
      title = property.get("thoroughfare");
      network = property.get("network");
      netRole = network ? network.get("role") : false;
      joinClassName = className === "Lease" ? "Tenant" : "Applicant";
      joinClassACL = new Parse.ACL;
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
      profileQuery = new Parse.Query("Profile").include("user").containedIn("email", emails).find();
      return Parse.Promise.when(mgrQuery, netQuery, profileQuery).then(function(mgrObj, netObj, profiles) {
        var email, emailsWithoutProfile, newProfileSaves, profile, profileACL, profileEmails, propRoleUsers, tntRoleUsers, user, _i, _j, _len, _len1;

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
        existingProfiles = profiles;
        newProfileSaves = profiles || new Array();
        profileEmails = new Array();
        emailsWithoutProfile = new Array();
        for (_i = 0, _len = profiles.length; _i < _len; _i++) {
          profile = profiles[_i];
          user = profile.get("user");
          if (user) {
            if (tntRole) {
              tntRoleUsers.add(user);
            }
            if (propRole && (mgrObj || netObj) || !netRole) {
              propRoleUsers.add(user);
            }
          }
          profileEmails.push(profile.get("email"));
        }
        emailsWithoutProfile = _.difference(emails, profileEmails);
        for (_j = 0, _len1 = emailsWithoutProfile.length; _j < _len1; _j++) {
          email = emailsWithoutProfile[_j];
          newProfileSaves.push(new Parse.Object("Profile").save({
            email: email,
            ACL: profileACL
          }));
        }
        return Parse.Promise.when(newProfileSaves);
      }, function(error) {
        console.log("role_query_error");
        return res.error('role_query_error');
      }).then(function() {
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
        console.log("profiles_not_saved");
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
              name: "" + (className.toLowerCase()) + "_invitation",
              forMgr: false,
              withAction: true,
              profile: req.user.get("profile"),
              email: profile.get("email"),
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
        console.log("joinClasses_not_saved");
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
        console.log('signup_error');
        return res.error('signup_error');
      }).then(function() {
        return res.success(leaseOrInquiry);
      }, function(error) {
        console.log("role_save_error");
        return res.error('role_save_error');
      });
    }, function(error) {
      console.log("bad_query");
      return res.error("bad_query");
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
        joinClassACL = new Parse.ACL;
        joinClassACL.setRoleRoleAccess(netRole, true);
        joinClassACL.setRoleWriteAccess(netRole, true);
        joinClasses = void 0;
        vstRoleUsers = vstRole.getUsers();
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
              var myJoinClassACL, user, vars;

              user = profile.get("user");
              myJoinClassACL = joinClassACL;
              if (user) {
                myJoinClassACL.setRoleAccess(user, true);
                myJoinClassACL.setWriteAccess(user, true);
              }
              vars = {
                network: network,
                status: user && user.id === req.user.id ? 'current' : status,
                profile: profile,
                accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
                ACL: myJoinClassACL
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

  Parse.Cloud.beforeSave("Profile", function(req, res) {
    if (!req.object.existed()) {
      req.object.set("createdBy", req.user);
    }
    return res.success();
  });

  Parse.Cloud.beforeSave(Parse.User, function(req, res) {
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
        return profile.save({
          email: email
        }).then(function() {
          req.object.set("profile", profile);
          return res.success();
        });
      }
    }, function() {
      return res.error("no_profile");
    });
  });

  Parse.Cloud.afterSave(Parse.User, function(req) {
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
            user: req.object,
            ACL: profileACL
          });
        }
        Parse.Cloud.useMasterKey();
        managerQuery = (new Parse.Query("Manager")).include('network.role').equalTo('profile', profile).find();
        tenantQuery = (new Parse.Query("Tenant")).include('property.role').include('lease.role').equalTo('profile', profile).find();
        notifQuery = (new Parse.Query("Notification")).equalTo('channel', "profiles-" + profile.id).find();
        return Parse.Promise.when(managerQuery, tenantQuery, notifQuery).then(function(managers, tenants, notifs) {
          var manager, managerACL, notif, notifACL, propRole, tenant, tntRole, vstRole, _i, _j, _k, _len, _len1, _len2, _results;

          if (managers) {
            for (_i = 0, _len = managers.length; _i < _len; _i++) {
              manager = managers[_i];
              managerACL = manager.getACL();
              managerACL.setReadAccess(req.object, true);
              managerACL.setWriteAccess(req.object, true);
              manager.setACL(managerACL);
              manager.save();
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
      var current, isPublic, networkACL, possible, randomId, role, visit, vstRole, _i;

      if (obj) {
        return res.error("" + obj.id + ":name_taken");
      }
      if (!req.object.existed()) {
        networkACL = new Parse.ACL();
        randomId = "";
        possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        for (_i = 1; _i < 16; _i++) {
          randomId += possible.charAt(Math.floor(Math.random() * possible.length));
        }
        current = "mgr-current-" + randomId;
        visit = "mgr-possible-" + randomId;
        req.object.set("public", true);
        networkACL.setPublicReadAccess(true);
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
      } else {
        isPublic = req.object.get("public");
        networkACL = req.object.getACL();
        if (networkACL.getPublicReadAccess() !== isPublic) {
          networkACL.setPublicReadAccess(isPublic);
          req.object.setACL(networkACL);
        }
        return res.success();
      }
    }, function() {
      return res.error("bad_query");
    });
  });

  Parse.Cloud.afterSave("Network", function(req) {
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
    } else if (!(req.object.get("thoroughfare") && req.object.get("locality") && (req.object.get("administrative_area_level_1") || req.object.get("administrative_area_level_2")) && req.object.get("country") && req.object.get("postal_code"))) {
      return res.error('insufficient_data');
    } else if (!req.object.get("title")) {
      return res.error('title_missing');
    }
    if (req.object.get("approx")) {
      req.object.set("offset", {
        lat: Math.floor(Math.random() * 100),
        lng: Math.floor(Math.random() * 100)
      });
    } else {
      req.object.set("offset", {
        lat: 50,
        lng: 50
      });
    }
    if (!req.object.existed()) {
      if (req.object.get("network")) {
        return (new Parse.Query("Network")).include("role").get(req.object.get("network").id, {
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
            roleACL.setPublicReadAccess(false);
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

  Parse.Cloud.beforeSave("Unit", function(req, res) {
    if (!req.object.get("property")) {
      return res.error('no_property');
    }
    if (!req.object.get("title")) {
      return res.error('no_title');
    }
    if (req.object.existed()) {
      return res.success();
    }
    Parse.Cloud.useMasterKey();
    return (new Parse.Query("Property")).get(req.object.get("property").id, {
      success: function(property) {
        var propertyACL;

        propertyACL = property.getACL();
        propertyACL.setPublicReadAccess(false);
        if (!(property.get("network") && property.get("network") === req.user.get("network"))) {
          propertyACL.setReadAccess(req.user.id, true);
          propertyACL.setWriteAccess(req.user.id, true);
        }
        req.object.set({
          user: req.user,
          property: property,
          network: property.get("network"),
          ACL: propertyACL
        });
        return res.success();
      },
      error: function() {
        return res.error("bad_query");
      }
    });
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
          withAction: false,
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
      unit_date_query.notEqualTo("objectId", req.object.id);
    }
    return unit_date_query.find().then(function(objs) {
      var ed, emails, obj, sd, _i, _len;

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
      emails = req.object.get("emails") || [];
      if (!(existed || req.object.get("forNetwork"))) {
        emails.push(req.user.getEmail());
      }
      req.object.set("emailsToProcess", emails);
      req.object.unset("emails");
      if (existed) {
        return res.success();
      }
      Parse.Cloud.useMasterKey();
      return (new Parse.Query("Property")).include('role').include('mgrRole').include('network.role').get(req.object.get("property").id, {
        success: function(property) {
          var channels, current, leaseACL, mgrRole, netRole, network, notificationACL, possible, propRole, randomId, role, savesToComplete, _j;

          network = property.get("network");
          mgrRole = property.get("mgrRole");
          propRole = property.get("role");
          req.object.set({
            user: req.user,
            confirmed: false,
            property: property,
            network: network
          });
          randomId = "";
          possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
          for (_j = 1; _j < 16; _j++) {
            randomId += possible.charAt(Math.floor(Math.random() * possible.length));
          }
          current = "tnt-current-" + randomId;
          leaseACL = new Parse.ACL();
          leaseACL.setPublicReadAccess(false);
          leaseACL.setRoleReadAccess(current, true);
          leaseACL.setRoleWriteAccess(current, true);
          if (mgrRole) {
            leaseACL.setRoleReadAccess(mgrRole, true);
            leaseACL.setRoleWriteAccess(mgrRole, true);
          }
          if (network) {
            netRole = network.get("role");
            if (!netRole) {
              return res.error("role_missing");
            }
            leaseACL.setRoleReadAccess(netRole, true);
            leaseACL.setRoleWriteAccess(netRole, true);
          }
          req.object.setACL(leaseACL);
          savesToComplete = [];
          if (!(property.get("user").id === req.user.id && req.object.get("forNetwork"))) {
            channels = ["properties-" + property.id];
            notificationACL = new Parse.ACL;
            notificationACL.setRoleReadAccess(mgrRole, true);
            notificationACL.setRoleWriteAccess(mgrRole, true);
            if (network) {
              notificationACL.setRoleReadAccess(netRole, true);
              notificationACL.setRoleWriteAccess(netRole, true);
              channels.push("networks-" + network.id);
            }
            savesToComplete.push(new Parse.Object("Notification").save({
              name: "lease_join",
              text: "New tenants have joined " + (property.get("title")),
              channels: channels,
              channel: "property-" + property.id,
              forMgr: true,
              withAction: false,
              profile: req.user.get("profile"),
              property: property,
              network: network,
              ACL: notificationACL
            }));
          }
          role = new Parse.Role(current, leaseACL);
          savesToComplete.push(role.save());
          return Parse.Promise.when(savesToComplete).then(function() {
            req.object.set("role", role);
            return res.success();
          }, function() {
            return res.error("role_error");
          });
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
    var active, emails, end_date, start_date, today, vars;

    today = new Date;
    start_date = req.object.get("start_date");
    end_date = req.object.get("end_date");
    if (!req.object.get("forNetwork")) {
      vars = {
        property: req.object.get("property"),
        unit: req.object.get("unit"),
        lease: req.object
      };
      req.user.save(vars);
    }
    active = start_date < today && today < end_date;
    if (active || !req.object.existed()) {
      (new Parse.Query("Unit")).get(req.object.get("unit").id, {
        success: function(unit) {
          var keys, noProperty, role, unitACL, unitACLList, _;

          unitACL = req.object.getACL();
          if (active) {
            unit.set("activeLease", req.object);
            _ = require("underscore");
            unitACLList = unitACL.toJSON();
            keys = _.keys(unitACLList);
            role = _.find(keys, function(key) {
              return key.indexOf("role:tnt-current" === 0);
            });
            if (role) {
              role = role.substr(5);
              unitACL.setRoleReadAccess(role, true);
              unitACL.setRoleWriteAccess(role, true);
            }
          }
          noProperty = !unit.get("property");
          if (noProperty) {
            unit.set({
              ACL: unitACL,
              property: req.object.get("property")
            });
          }
          if (active || noProperty) {
            return unit.save();
          }
        }
      });
    }
    emails = req.object.get("emailsToProcess");
    if (emails && emails.length > 0) {
      return Parse.Cloud.run("AddTenants", {
        objectId: req.object.id,
        emails: emails,
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
    return (new Parse.Query("Unit")).include('property.mgrRole').include('property.network.role').get(req.object.get("unit").id, {
      success: function(unit) {
        var isPublic, listingACL, mgrRole, netRole, network, property, propertyIsPublic;

        property = unit.get("property");
        propertyIsPublic = property.getACL().getPublicReadAccess();
        if (!req.object.existed()) {
          network = property.get("network");
          listingACL = new Parse.ACL();
          listingACL.setPublicReadAccess(propertyIsPublic);
          if (network) {
            netRole = network.get("role");
            listingACL.setRoleWriteAccess(netRole, true);
            listingACL.setRoleReadAccess(netRole, true);
          }
          mgrRole = property.get("mgrRole");
          if (mgrRole) {
            listingACL.setRoleWriteAccess(mgrRole, true);
            listingACL.setRoleReadAccess(mgrRole, true);
          }
          listingACL.setWriteAccess(req.user, true);
          listingACL.setReadAccess(req.user, true);
          req.object.set({
            property: property,
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

  Parse.Cloud.beforeSave("Tenant", function(req, res) {
    if (req.object.get("accessToken") === "AZeRP2WAmbuyFY8tSWx8azlPEb") {
      req.object.unset("accessToken");
      return res.success();
    }
    Parse.Cloud.useMasterKey();
    return (new Parse.Query("Lease")).include('role').include("property.mgrRole").include("property.role").include("property.network.role").get(req.object.get("lease").id, {
      success: function(lease) {
        var mgrQuery, mgrRole, mgrUsers, netQuery, netRole, netUsers, network, newStatus, profileQuery, propRole, property, status, tntRole;

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
            var activity, activityACL, notification, notificationACL, profileACL, savesToComplete, tenantACL, title, user;

            savesToComplete = [];
            user = profile.get("user");
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
                  accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
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
              if (mgrRole || netRole || propRole) {
                profileACL = profile.getACL();
                if (propRole) {
                  profileACL.setRoleReadAccess(propRole, true);
                }
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
                  accessToken: "AZeRP2WAmbuyFY8tSWx8azlPEb",
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

  Parse.Cloud.beforeSave("Concerige", function(req, res) {
    Parse.Cloud.useMasterKey();
    return (new Parse.Query("Property")).include('role').get(req.object.get("property").include("network.role").id, {
      success: function(property) {
        var mgrQuery, mgrRole, mgrUsers, netQuery, netRole, netUsers, network, newStatus, profileQuery, status;

        status = req.object.get("status");
        newStatus = req.object.get("newStatus");
        mgrRole = property.get("mgrRole");
        network = property.get("network");
        netRole = network.get("role");
        mgrUsers = mgrRole.getUsers();
        mgrQuery = mgrUsers.query().equalTo("objectId", req.user.id).first();
        netUsers = netRole.getUsers();
        netQuery = netUsers.query().equalTo("objectId", req.user.id).first();
        profileQuery = (new Parse.Query("Profile")).include("user").equalTo("objectId", req.object.get("profile").id).first();
        return Parse.Promise.when(mgrQuery, profileQuery, netQuery).then(function(mgrObj, profile, netObj) {
          var concerigeACL, notificationACL, profileACL, savesToComplete, title, user;

          savesToComplete = [];
          user = profile.get("user");
          if (!req.object.existed()) {
            concerigeACL = new Parse.ACL;
            concerigeACL.setRoleReadAccess(mgrRole, true);
            concerigeACL.setRoleWriteAccess(mgrRole, true);
            concerigeACL.setReadAccess(netRole, true);
            concerigeACL.setWriteAccess(netRole, true);
            req.object.setACL(concerigeACL);
          }
          if (mgrObj) {
            if (req.object.existed() && status && status === 'pending' && newStatus && newStatus === 'current') {
              concerigeACL = req.object.getACL();
              concerigeACL.setRoleReadAccess(netRole, true);
              concerigeACL.setRoleWriteAccess(netRole, true);
              savesToComplete.push(property.save({
                network: network,
                ACL: concerigeACL
              }));
            } else {
              newStatus = 'invited';
              title = property.get("title");
              notificationACL = new Parse.ACL;
              notificationACL.setRoleReadAccess(netRole, true);
              notificationACL.setRoleWriteAccess(netRole, true);
              savesToComplete.push(new Parse.Object("Notification").save({
                name: "property_invitation",
                text: "You have been requested to manage " + title,
                channels: ["networks-" + network.id],
                channel: "networks-" + network.id,
                forMgr: true,
                withAction: true,
                profile: req.user.get("profile"),
                network: network,
                ACL: notificationACL
              }));
            }
            req.object.set("status", newStatus);
          } else {
            if (!netObj) {
              return res.error();
            }
            profileACL = profile.getACL();
            profileACL.setRoleReadAccess(mgrRole, true);
            savesToComplete.push(profile.save({
              ACL: profileACL
            }));
            if (req.object.existed() && status && status === 'invited' && newStatus && newStatus === 'current') {
              concerigeACL = req.object.getACL();
              concerigeACL.setRoleReadAccess(netRole, true);
              concerigeACL.setRoleWriteAccess(netRole, true);
              savesToComplete.push(property.save({
                network: network,
                ACL: concerigeACL
              }));
            } else {
              newStatus = 'pending';
              title = network.get("title");
              notificationACL = new Parse.ACL;
              notificationACL.setRoleReadAccess(mgrRole, true);
              notificationACL.setRoleWriteAccess(mgrRole, true);
              savesToComplete.push(new Parse.Object("Notification").save({
                name: "network_inquiry",
                text: "" + title + " wants to manage your property",
                channels: ["properties-" + property.id],
                channel: "properties-" + property.id,
                forMgr: false,
                withAction: true,
                profile: req.user.get("profile"),
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

  Parse.Cloud.beforeSave("Manager", function(req, res) {
    if (req.object.get("accessToken") === "AZeRP2WAmbuyFY8tSWx8azlPEb") {
      req.object.unset("accessToken");
      return res.success();
    }
    Parse.Cloud.useMasterKey();
    return (new Parse.Query("Network")).include('role').include('vstRole').get(req.object.get("network").id, {
      success: function(network) {
        var netQuery, netRole, netUsers, newStatus, profileQuery, status, vstRole;

        status = req.object.get("status");
        newStatus = req.object.get("newStatus");
        netRole = network.get("role");
        vstRole = network.get("vstRole");
        netUsers = netRole.getUsers();
        netQuery = netUsers.query().equalTo("objectId", req.user.id).first();
        profileQuery = (new Parse.Query("Profile")).include("user").equalTo("objectId", req.object.get("profile").id).first();
        return Parse.Promise.when(netQuery, profileQuery).then(function(netObj, profile) {
          var managerACL, notification, notificationACL, profileACL, savesToComplete, title, user;

          savesToComplete = [];
          user = profile.get("user");
          if (!req.object.existed()) {
            managerACL = new Parse.ACL;
            managerACL.setRoleReadAccess(netRole, true);
            managerACL.setRoleWriteAccess(netRole, true);
            if (user) {
              managerACL.setReadAccess(user, true);
              managerACL.setWriteAccess(user, true);
            }
            req.object.setACL(managerACL);
          }
          if (netObj) {
            if (req.object.existed() && status && status === 'pending' && newStatus && newStatus === 'current') {
              if (user) {
                savesToComplete.push(user.save("network", network));
                netRole.getUsers().add(user);
                savesToComplete.push(netRole.save());
              }
              managerACL = req.object.getACL();
              managerACL.setRoleReadAccess(vstRole, true);
              managerACL.setRoleWriteAccess(vstRole, true);
              req.object.setACL(managerACL);
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
            if (req.object.get("profile").id !== req.user.get("profile").id) {
              return res.error();
            }
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
              managerACL = req.object.getACL();
              managerACL.setRoleReadAccess(vstRole, true);
              managerACL.setRoleWriteAccess(vstRole, true);
              req.object.setACL(managerACL);
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

  Parse.Cloud.beforeSave("Activity", function(req, res) {
    var activityACL;

    if (req.object.existed()) {
      return res.success();
    }
    if (req.object.get("accessToken") === "AZeRP2WAmbuyFY8tSWx8azlPEb") {
      req.object.unset("accessToken");
      return res.success();
    }
    activityACL = new Parse.ACL;
    activityACL.setReadAccess(req.user, true);
    activityACL.setWriteAccess(req.user, true);
    if (req.object.get("property")) {
      Parse.Cloud.useMasterKey();
      return (new Parse.Query("Property")).include("role").include("mgrRole").include("network.role").get(req.object.get("property").id, {
        success: function(property) {
          var mgrRole, netRole, network, propRole;

          propRole = property.get("role");
          mgrRole = property.get("mgrRole");
          network = property.get("network");
          if (req.object.get("public")) {
            activityACL.setPublicReadAccess(true);
          } else {
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
          }
          req.object.set({
            property: property,
            center: property.get("center"),
            network: property.get("network"),
            ACL: activityACL
          });
          return res.success();
        },
        error: function() {
          return res.error("bad_query");
        }
      });
    } else {
      activityACL.setPublicReadAccess(true);
      req.object.set({
        profile: req.user.get("profile"),
        "public": true,
        ACL: activityACL
      });
      return res.success();
    }
  });

  Parse.Cloud.beforeSave("Comment", function(req, res) {
    var CommentACL;

    if (!req.object.get("activity")) {
      return res.error("activity_missing");
    }
    if (req.object.existed()) {
      return res.success();
    }
    CommentACL = new Parse.ACL;
    CommentACL.setPublicReadAccess(true);
    CommentACL.setReadAccess(req.user, true);
    CommentACL.setWriteAccess(req.user, true);
    req.object.setACL(CommentACL);
    return res.success();
  });

  Parse.Cloud.afterSave("Comment", function(req) {
    var query;

    Parse.Cloud.useMasterKey();
    query = new Parse.Query("Activity");
    return query.get(req.object.get("activity").id, {
      success: function(activity) {
        activity.increment("commentCount");
        return activity.save();
      }
    });
  });

}).call(this);
