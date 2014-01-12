(function() {
  define({
    fields: {
      title: "Title",
      body: "Body",
      email: "Email",
      phone: "Phone",
      website: "Website",
      status: "Status",
      name: "Name",
      posted: "Posted",
      posted_at: "Posted at"
    },
    classes: {
      Activity: "Activity",
      Profile: "Profile",
      lease: "lease",
      Lease: "Lease",
      Leases: "Leases",
      Network: "Network",
      Unit: "Unit",
      address: "Address",
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
      Listing: "Listing",
      Listings: "Listings",
      photo: "Photo",
      Photos: "Photos",
      Posts: "Posts",
      status: "Status",
      question: "Question",
      tip: "Tip"
    },
    actions: {
      go: "Go",
      go_to: "Go to",
      show: "Show",
      post: "Post",
      post_to: "Post to",
      also_post_to: "Also post to",
      join: "Join",
      manage: "Manage",
      search: "Search",
      destroy: "Destroy",
      upload: "Upload",
      remove: "remove",
      "delete": "Delete",
      submit: "Submit",
      next: "Next",
      finish: "Finish",
      cancel: "Cancel",
      close: "Close",
      save: "Save",
      update: "Update",
      create: "Create",
      back: "Back",
      edit: "Edit",
      follow: "Follow",
      unfollow: "Unfollow",
      undo: "Undo",
      link: "Link",
      like: "Like",
      leave: "Leave",
      apply: "Apply",
      select: "Select",
      live_at: "Live at",
      revoke_access: "Revoke access",
      confirm: "Confirm",
      accept: "Accept",
      ignore: "Ignore",
      upgrade: "Upgrade",
      add_more: "Add more",
      add_another: "Add another",
      add_comment: "Add a comment",
      add_files: "Add files",
      add_photo: "Add photo",
      add_time: "Add event time",
      add_photos: "Add photos",
      add_extra_details: "Add extra details",
      choose_file: "Choose file",
      choose_photo: "Choose photo",
      edit_picture: "Change Picture",
      add_x_more: "Add <strong>x</strong> more",
      make_primary: "Make primary",
      select_contacts: "Select contacts",
      changes_saved: "Changes Saved.",
      request_sent: "Request sent."
    },
    countries: {
      CA: "Canada",
      US: "United States"
    },
    dates: {
      moment_format: "MM/DD/YYYY",
      datepicker_format: "mm/dd/yyyy",
      per_month: "per month",
      date: "Date",
      start_date: "Start Date",
      end_date: "End Date",
      add_end_date: "Add end date",
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
      lease_join: function(person, property) {
        return "<strong>" + (_.escape(person)) + "</strong> has joined <strong>" + (_.escape(property)) + "</strong>";
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
    activity: {
      building: "Post to your building",
      people_who_like_this: "People who like this",
      be_the_first_to_like_this: "Be the first one to like this",
      following_no_one: function(name) {
        return "<em>" + name + "</em> isn't following anyone";
      },
      followed_by_no_one: function(name) {
        return "<em>" + name + "</em> isn't followed by anyone";
      },
      you_arent_following_anyone: "You aren't following anyone, so there's nothing here!",
      find_your_interests: "Find your favourite locations, buildings, and people to follow.",
      be_the_first_to_like_this: "Be the first one to like this",
      exhausted: "There are no more items to display."
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
      "in": "in",
      eg: "E.g., "
    },
    affirmations: {
      yes: "Yes",
      no: "No"
    },
    conjuctions: {
      or: "or",
      and: "and"
    },
    verbs: {
      beginning: "Beginning",
      loading: "Loading",
      following: "Following",
      followed_by: "Followed by",
      explore: "Explore",
      manage: "Manage",
      view: "View"
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
      size: "Size",
      link: "link",
      building: "Building",
      inside: "Inside",
      outside: "Outside",
      following: "Following",
      followers: "Followers",
      suggestions: "Suggestions",
      history: "History",
      tenants: "Tenants",
      roommates: "Roommates",
      you: "You",
      people: "People",
      places: "Places",
      sample_email: "keigan@example.com",
      comments: "Comments",
      more_comment: function(num) {
        if (num > 1) {
          return "more comments";
        } else {
          return "more comment";
        }
      },
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
      small: "Small",
      big: "Big",
      done: "Done",
      selected: "Selected",
      advanced: "Advanced",
      "new": "new",
      unsaved: "Unsaved",
      linked: "Linked",
      liked: "Liked",
      followed: "Followed",
      joined: "Joined",
      open: "Open",
      closed: "Closed",
      received: "Received",
      recently_added: "Recently Added",
      all: "All",
      "public": "Public",
      "private": "Private",
      primary: "Primary",
      approximate: "Approximate",
      exact: "Exact",
      landlord_only: "Landlord Only",
      admin: "admin",
      not_specified: "Not specified"
    },
    form: {
      find_contacts_in: 'Find contacts in',
      post_as_property: "Post as property",
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
    oauth: {
      error: "We could not reach the server.",
      access_denied: "You cancelled the process.",
      invalid_token: "The token is invalid. You may need to sign in again.",
      unverified_token: "We did not receive the correct response. If this error persists, this could indicate a serious problem."
    },
    warnings: {
      no_undo: "This action cannot be undone."
    },
    errors: {
      bad_save: "Something went wrong. Changes were not saved.",
      no_start_date: "You cannot create an event without a start date.",
      no_data: "No data sent.",
      no_picture: "No picture was attached.",
      no_end_date: "You have not specified an end date.",
      fourOhFour: "Error 404",
      not_found: "Oops. We don't have anything at this URL.",
      access_denied: "Access denied",
      no_permission: "You do not have permission to do that.",
      unknown: "An unknown error has occured.",
      not_logged_in: "You are not logged in.",
      geocode_error: "We were unable to determine your location.",
      no_results: "No results found.",
      not_yet_accepted: "You haven't been accepted into this network yet. <br/> You can only see what is publicly visible. Most things will not work correctly.",
      pending_approval: "Pending approval.",
      comment_load: "Comments failed to load. Please try again."
    }
  });

}).call(this);
