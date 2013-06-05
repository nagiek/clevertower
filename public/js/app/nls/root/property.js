(function() {
  define({
    actions: {
      search: "Search",
      geolocate: "Geolocate Me",
      new_property: "New Property",
      setup_property: "Setup Property",
      edit_picture: "Change Picture",
      go_to_network: "Go to network",
      add_a_property: "Add a property",
      join_or_create_to_start: "Join or create a property to get started",
      join_property_at: function(title) {
        return "Create your lease at <em>" + (_.escape(title)) + "</em>";
      }
    },
    menu: {
      dashboard: "Dashboard",
      day_to_day: "Day to Day",
      reports: "Reports",
      income: "Income",
      expenses: "Expenses",
      other: "Other",
      actions: "Actions",
      building: "Building",
      tenants: "Tenant Directory",
      message_board: "Message Board",
      tasks: "Tasks",
      listings: "Listings",
      applicants: "Applicants",
      add_lease: "Add lease",
      add_tenants: "Add tenants",
      add_income: "Add income",
      add_expense: "Add expense",
      add_post: "Add a post",
      add_task: "Add a task",
      add_listing: "Advertise",
      occupancy: "Occupancy",
      incomes: "Income",
      expenses: "Expenses",
      cash_transactions: "Cash Transactions",
      lease_history: "Lease History",
      edit_property: "Edit Property",
      edit_photos: "Edit Photos",
      edit_units: "Edit Units",
      edit_managers: "Edit Managers",
      managers: "Managers",
      view_public: "See Public View",
      view_tenant: "See Tenant View"
    },
    network: {
      edit: "Edit network",
      setup: "Set up network",
      claim_domain: "Claim your domain name.",
      must_be_done: "Before you can begin adding properties to CleverTower, you must create your network.\nOnly people who you invite to your network can edit properties.\nYou can change these settings at any time.",
      give_network_a_title: "Give your network a title.",
      can_be_anything: "Can be anything you like."
    },
    structure: {
      vacancies: "Vacancies",
      units_control: "Units Control"
    },
    form: {
      marketing: "Marketing",
      contact: "Contact",
      building: "Building",
      features: "Features",
      amenities: "Amenities",
      included: "Included"
    },
    search: {
      map_instructions: "Find your building on the map. If the building is on CleverTower, you'll have the chance to join.",
      awaiting_search: "Awaiting search.",
      no_results: "No nearby buildings."
    },
    empty: {
      properties: "You don't have any properties yet.",
      units: "You don't have any units yet.",
      leases: "You don't have any leases yet.",
      photos: "You don't have any photos yet."
    },
    fields: {
      description: "Description",
      phone: "Phone",
      email: "Email",
      website: "Website",
      title: "Title",
      photos: "Photos",
      property_type: {
        label: "Property Type",
        condo: "Condo",
        apartment: "Apartment"
      },
      year: "Year",
      mls: "MLS",
      air_conditioning: "Air conditioning",
      back_yard: "Back yard",
      balcony: "Balcony",
      cats_allowed: "Cats allowed",
      concierge: "Concierge",
      dogs_allowed: "Dogs allowed",
      doorman: "Doorman",
      elevator: "Elevator",
      exposed_brick: "Exposed brick",
      fireplace: "Fireplace",
      front_yard: "Front yard",
      gym: "Gym",
      laundry: "Laundry",
      indoor_parking: "Indoor parking",
      outdoor_parking: "Outdoor parking",
      park: "Park",
      pool: "Pool",
      sauna: "Sauna",
      wheelchair: "Wheelchair access",
      electricity: "Electricity",
      furniture: "Furniture",
      gas: "Gas",
      heat: "Heat",
      hot_water: "Hot water"
    },
    errors: {
      name_reserved: "That name is reserved by CleverTower. Please choose another.",
      name_invalid: "You did not enter a valid name. Make sure there are only lowercase letters.",
      name_too_short: "The name must be at least four letters long",
      name_too_short: "The name cannot be longer than 31 characters.",
      name_missing: "You must enter a name.",
      name_taken: function(id) {
        return "<p>This name has been taken by an existing network.</p>\n<p>\n  <a href=\"/network/" + (_.escape(id)) + "\" class=\"btn btn-warning\">View network</a>\n  <a class=\"btn close\">Close</a>\n</p>";
      },
      network_not_set: "You have not joined a network yet.",
      invalid_address: "You must add an address.",
      insufficient_data: "We were unable to determine your address.",
      no_geolocaiton: "Your browser doesn't support geolocation.",
      taken_by_network: function(id) {
        return "Your group already has <a href='/properties/" + (_.escape(id)) + "'>a property</a> at this address.";
      },
      taken_by_user: function(id) {
        return "You already have <a href='/properties/" + (_.escape(id)) + "'>a property</a> at this address.";
      },
      "success/error was not called": "<strong>D'oh!</strong> Something went wrong. Please try again.",
      access_denied: "You do not have access to the property.",
      missing: "You must select a property.",
      title_missing: "A title is required."
    }
  });

}).call(this);
