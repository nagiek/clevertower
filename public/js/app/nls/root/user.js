(function() {
  define({
    actions: {
      back_to_profile: "Back to profile"
    },
    manager_menu: {
      properties: "Properties",
      tenants: "Tenants",
      reports: "Reports",
      domain: "Domain"
    },
    menu: {
      view_profile: "Profile",
      edit_profile: "Edit profile",
      edit_my_profile: "Edit my profile",
      account: "Account",
      privacy: "Privacy",
      apps: "Apps",
      connect_to_continue: "Connect to continue",
      account_settings: "Account settings",
      privacy_settings: "Privacy settings",
      profile_menu: "Profile menu"
    },
    building: {
      my_building: "My building",
      past_leases: "Past leases"
    },
    app_descriptions: {
      facebook: "Connect with friends and the world around you on Facebook."
    },
    show: {
      photo: function(name) {
        return "" + (_.escape(name)) + "'s photo";
      }
    },
    setup: {
      welcome_message: "Welcome to CleverTower",
      performing_setup_for: "Performing setup for",
      existing_notifications: "You have existing offers to join or manage properties. Please select from the list below."
    },
    fields: {
      name: "Name",
      first_name: "First Name",
      last_name: "Last Name",
      bio: "Bio",
      website: "Website",
      phone: "Phone",
      gender: {
        label: "Gender",
        male: "Male",
        female: "Female"
      },
      birthday: "Birthday",
      avatar: "Picture"
    },
    privacy: {
      building: {
        label: "Tenants in my building can see I live here.",
        description: "Your unit, lease, and other confidential data will not be revealed."
      },
      unit: {
        label: "...Can see my unit",
        description: "Other tenants will be able to see which unit you live in."
      }
    },
    empty: {
      inquiries: "You have not applied to any listings yet",
      activities: {
        self: "You haven't done anything yet!",
        index: "Nothing's happened so far.",
        other: function(name) {
          return "" + (_.escape(name)) + " has no activity.";
        }
      },
      likes: {
        self: "You haven't liked anything yet!",
        index: "Nothing's been liked so far.",
        other: function(name) {
          return "" + (_.escape(name)) + " has no likes.";
        }
      }
    },
    form: {
      share: [["Share your thoughts.", "What's on your mind?"], ["What defines your area?", "Share what you like nearby."]],
      bulk_edit: "Edit users",
      building: {
        label: "Visibility: Building",
        description: "These fields can be seen by other people in your building if your profile is visible."
      },
      landlord: {
        label: "Visibility: Landlord",
        description: "These fields are visible to your landlord, but cannot be seen by tenants."
      }
    },
    notices: {
      create: 'Tenants added to lease',
      update: 'User was successfully updated.',
      self_update: 'You have successfully updated your profile.',
      bulk_update: 'Users were successfully updated.'
    },
    errors: {
      logged_in: "You must be logged in to do that.",
      invalid_birthday: "You did not enter a correct birthday."
    }
  });

}).call(this);
