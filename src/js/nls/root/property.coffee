define
  actions:
    search:               "Search"
    geolocate:            "Geolocate Me"
    new_property:         "New Property"
    setup_property:       "Setup Property"
    edit_picture:         "Change Picture"
  menu:                     
    dashboard:            "Dashboard"
    day_to_day:           "Day to Day"
    reports:              "Reports"
    income:               "Income"
    expenses:             "Expenses"
    other:                "Other"
    actions:              "Actions"
    building:             "Building"
    tenants:              "Tenant Directory"
    message_board:        "Message Board"
    tasks:                "Tasks"
    listings:             "Listings"
    applicants:           "Applicants"
    add_lease:            "Add lease"
    add_tenants:          "Add tenants"
    add_income:           "Add income"
    add_expense:          "Add expense"
    add_post:             "Add a post"
    add_task:             "Add a task"
    add_listing:          "Advertise"
    occupancy:            "Occupancy"
    incomes:              "Income"
    expenses:             "Expenses"
    cash_transactions:    "Cash Transactions"
    lease_history:        "Lease History"
    edit_property:        "Edit Property"
    edit_photos:          "Edit Photos"
    edit_units:           "Edit Units"
    edit_managers:        "Edit Managers"
    managers:             "Managers"
    view_public:          "See Public View"
    view_tenant:          "See Tenant View"
  structure:              
    vacancies:            "Vacancies"
    units_control:        "Units Control"
  form:                                                   
    marketing:          "Marketing"
    contact:            "Contact"
    building:           "Building"
    features:           "Features"
    amenities:          "Amenities"
    included:           "Included"
  collection:             
    empty:                "You don't have any properties yet."
  fields:
    description         : "Description"
    phone               : "Phone"
    email               : "Email"
    website             : "Website"
    title               : "Title"
    photos              : "Photos"
    property_type       : 
      label:              "Property Type"
      condo:              "Condo"
      apartment:          "Apartment"
    year                : "Year"
    mls                 : "MLS"
    air_conditioning    : "Air conditioning"
    back_yard           : "Back yard"
    balcony             : "Balcony"
    cats_allowed        : "Cats allowed"
    concierge           : "Concierge"
    dogs_allowed        : "Dogs allowed"
    doorman             : "Doorman"
    elevator            : "Elevator"
    exposed_brick       : "Exposed brick"
    fireplace           : "Fireplace"
    front_yard          : "Front yard"
    gym                 : "Gym"
    laundry             : "Laundry"
    indoor_parking      : "Indoor parking"
    outdoor_parking     : "Outdoor parking"
    park                : "Park"
    pool                : "Pool"
    sauna               : "Sauna"
    wheelchair          : "wheelchair"
    electricity         : "Electricity"
    furniture           : "Furniture"
    gas                 : "Gas"
    heat                : "Heat"
    hot_water           : "Hot water"
  
  errors:
    invalid_address:                "You must add an address."
    insufficient_data:              "We were unable to determine your address."
    no_geolocaiton:                 "Your browser doesn't support geolocation."
    taken_by_network:       (id) -> "Your group already has <a href='/properties/#{_.escape(id)}'>a property</a> at this address."
    taken_by_user:          (id) -> "You already have <a href='/properties/#{_.escape(id)}'>a property</a> at this address."
    "success/error was not called": "<strong>D'oh!</strong> Something went wrong. Please try again."
    access_denied:                  "You do not have access to the property."
    missing:                        "You must select a property."
    title_missing:                  "A title is required."