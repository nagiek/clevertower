(function() {
  define({
    fields: {
      title: "Title",
      body: "Body",
      status: "Status",
      name: "Name",
      posted: "Posted"
    },
    classes: {
      lease: "lease",
      Lease: "Lease",
      Leases: "Leases",
      Network: "Network",
      Unit: "Unit",
      Tenant: "Tenant",
      Tenants: "Tenants",
      unit: "unit",
      units: "units",
      Units: "Units",
      Properties: "Properties",
      Managers: "Managers",
      tasks: "tasks",
      finances: "finances",
      notifications: "Notifications",
      Applicants: "Applicants",
      Inquiries: "Inquiries",
      listings: "listings",
      Listing: "Listing",
      Listings: "Listings",
      Photos: "Photos",
      Posts: "Posts",
      status: "status",
      question: "question",
      tip: "tip"
    },
    actions: {
      go: "Go",
      go_to: "Go to",
      show: "Show",
      post: "Post",
      join: "Join",
      manage: "Manage",
      search: "Search",
      destroy: "Destroy",
      upload: "Upload",
      remove: "remove",
      "delete": "Delete",
      submit: "Submit",
      next: "Next",
      cancel: "Cancel",
      close: "Close",
      save: "Save",
      update: "Update",
      create: "Create",
      back: "Back",
      edit: "Edit",
      undo: "Undo",
      link: "Link",
      leave: "Leave",
      apply: "Apply",
      live_at: "Live at",
      revoke_access: "Revoke access",
      confirm: "Confirm",
      accept: "Accept",
      ignore: "Ignore",
      upgrade: "Upgrade",
      add_more: "Add more",
      add_another: "Add another",
      add_files: "Add files",
      add_photos: "Add photos",
      add_extra_details: "Add extra details",
      choose_file: "Choose file",
      choose_photo: "Choose photo",
      add_x_more: "Add <strong>x</strong> more",
      make_primary: "Make primary",
      changes_saved: "Changes Saved.",
      request_sent: "Request sent."
    },
    dates: {
      moment_format: "MM/DD/YYYY",
      datepicker_format: "mm/dd/yyyy",
      per_month: "per month",
      date: "Date",
      day: "Day",
      month: "Month",
      year: "Year",
      months: {
        short: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
      }
    },
    notifications: {
      img: "Notification Image",
      empty: {
        memo: "No new notifications",
        withAction: "No new requests or invitations",
        all: "No notifications, requests or invitations"
      },
      new_inquiry: function(person, property) {
        return "<strong>" + (_.escape(person)) + "</strong> has applied to join <strong>" + (_.escape(property)) + "</strong>";
      },
      inquiry_invitation: {
        invited: function(person, property) {
          return "<strong>" + (_.escape(person)) + "</strong> has indicated you are applying to join <strong>" + (_.escape(property)) + "</strong>";
        },
        accept: function(property) {
          return "You have accepted the invitation to join <strong>" + (_.escape(property)) + "</strong>";
        },
        ignore: function(property) {
          return "You have ignored the invitation to join <strong>" + (_.escape(property)) + "</strong>";
        }
      },
      lease_invitation: {
        invited: function(person, property) {
          return "You have been invited to a lease at <strong>" + (_.escape(property)) + "</strong>";
        },
        accept: function(property) {
          return "You have accepted the invitation at <strong>" + (_.escape(property)) + "</strong>";
        },
        ignore: function(property) {
          return "You have ignored the invitation at <strong>" + (_.escape(property)) + "</strong>";
        }
      },
      network_invitation: {
        invited: function(person, network) {
          return "<strong>" + (_.escape(person)) + "</strong> invited you to join their network <strong>" + (_.escape(network)) + "</strong>";
        },
        accept: function(network) {
          return "You have accepted the invitation to join <strong>" + (_.escape(network)) + "</strong>";
        },
        ignore: function(network) {
          return "You have ignored the invitation to join <strong>" + (_.escape(network)) + "</strong>";
        }
      },
      manager_inquiry: {
        invited: function(person, network) {
          return "<strong>" + (_.escape(person)) + "</strong> wants to be a manager in your network.";
        },
        accept: function(person) {
          return "You have accepted <strong>" + (_.escape(person)) + "</strong>'s request.";
        },
        ignore: function(person) {
          return "You have ignored <strong>" + (_.escape(person)) + "</strong>'s request.";
        }
      },
      network_inquiry: {
        invited: function(network, property) {
          return "<strong>" + (_.escape(person)) + "</strong> wants to manage <strong>" + (_.escape(property)) + "</strong>.";
        },
        accept: function(network) {
          return "You have accepted <strong>" + (_.escape(network)) + "</strong>'s request.";
        },
        ignore: function(network) {
          return "You have ignored <strong>" + (_.escape(network)) + "</strong>'s request.";
        }
      }
    },
    status: {
      ok: "OK",
      unsaved: "Unsaved",
      vacant: "Vacant",
      pending: "Pending",
      confirmed: "Confirmed"
    },
    prepositions: {
      where: "Where",
      when: "When",
      about: "About",
      of: "of",
      on: "on",
      off: "off",
      at: "at",
      eg: "E.g., "
    },
    conjuctions: {
      or: "or",
      and: "and"
    },
    verbs: {
      beginning: "Beginning",
      loading: "Loading",
      explore: "Explore",
      manage: "Manage"
    },
    expressions: {
      delete_forever: "Delete forever",
      are_you_sure: "Are you sure?",
      get_started: "Get started",
      skip_this_step: "Skip this step",
      see_all: "See all"
    },
    nouns: {
      home: "Home",
      cover_photo: "Cover Photo",
      link: "link",
      building: "Building",
      history: "History",
      tenants: "Tenants",
      roommates: "Roommates",
      you: "You",
      people: "People",
      places: "Places",
      sample_email: "keigan@example.com",
      comments: "Comments",
      public_activity: "Public Activity",
      likes: "Likes",
      accommodation: "Accommodation",
      optional_description: "Optional description",
      extra_details: "Extra details"
    },
    order: {
      first: "First",
      last: "Last"
    },
    adjectives: {
      small: "Big",
      big: "Small",
      done: "Done",
      "new": "new",
      unsaved: "Unsaved",
      linked: "Linked",
      joined: "Joined",
      open: "Open",
      closed: "Closed",
      received: "Received",
      recently_added: "Recently Added",
      all: "All",
      "public": "Public",
      "private": "Private",
      primary: "Primary",
      landlord_only: "Landlord Only",
      admin: "admin",
      not_specified: "Not specified"
    },
    form: {
      find_people_using: 'Find people using',
      center_on_property: "Center on property",
      operations: "Operations",
      info: "Info",
      required: "Required",
      lowercase_only: "Lowercase letters (a-z) only. No spaces.",
      comma_separated: "Enter a comma-separated list of email addresses.",
      select: {
        select_value: "- Select a value -",
        numeric: "Numeric (1 ➡ 2)",
        alphabetical: "Alphabetical (A ➡ B)"
      }
    },
    warnings: {
      no_undo: "This action cannot be undone."
    },
    errors: {
      bad_save: "Something went wrong. Changes were not saved.",
      access_denied: "Access denied",
      no_permission: "You do not have permission to do that.",
      unknown: "An unknown error has occured.",
      not_logged_in: "You are not logged in.",
      no_results: "No results found.",
      not_yet_accepted: "You haven't been accepted into this network yet. <br/> You can only see what is publicly visible. Most things will not work correctly.",
      pending_approval: "Pending approval."
    }
  });

}).call(this);
