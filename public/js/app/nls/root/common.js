(function() {

  define({
    menu: {
      home: "Home",
      search: "Search"
    },
    fields: {
      title: "Title",
      name: "Name"
    },
    classes: {
      lease: "lease",
      Lease: "Lease",
      Leases: "Leases",
      Network: "Network",
      Unit: "Unit",
      Tenant: "Tenant",
      unit: "unit",
      units: "units",
      Units: "Units",
      Properties: "Properties",
      Managers: "Managers",
      tasks: "tasks",
      finances: "finances"
    },
    actions: {
      go: "Go",
      go_to: "Go to",
      show: "Show",
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
      back: "Back",
      edit: "Edit",
      undo: "Undo",
      link: "Link",
      leave: "Leave",
      revoke_access: "Revoke access",
      confirm: "Are you sure?",
      add_more: "Add more",
      add_another: "Add another",
      add_files: "Add files",
      add_photos: "Add photos",
      choose_file: "Choose file",
      choose_photo: "Choose photo",
      add_x_more: "Add <strong>x</strong> more",
      changes_saved: "Changes Saved."
    },
    dates: {
      moment_format: "MM/DD/YYYY",
      datepicker_format: "mm/dd/yyyy",
      per_month: "Per month",
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
      empty: "No new notifications",
      text: {
        lease_invitation: function(person) {
          return "You have been invited to a lease at <strong>" + (_.escape(property)) + "</strong>";
        },
        lease_application: function(person, property) {
          return "<strong>" + (_.escape(person)) + "</strong> has applied to join <strong>" + (_.escape(property)) + "</strong>";
        },
        tenant_application: function(person, property) {
          return "<strong>" + (_.escape(person)) + "</strong> has applied to join <strong>" + (_.escape(property)) + "</strong>";
        }
      }
    },
    status: {
      unsaved: "Unsaved",
      vacant: "Vacant",
      pending: "Pending",
      confirmed: "Confirmed"
    },
    prepositions: {
      of: "of",
      at: "at",
      eg: "E.g., "
    },
    verbs: {
      loading: "Loading"
    },
    nouns: {
      link: "link",
      you: "You",
      sample_email: "keigan@example.com"
    },
    order: {
      first: "First",
      last: "Last"
    },
    adjectives: {
      unsaved: "Unsaved",
      linked: "Linked",
      all: "All",
      "private": "Private",
      landlord_only: "Landlord Only",
      admin: "admin"
    },
    form: {
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
      not_logged_in: "You are not logged in."
    }
  });

}).call(this);
