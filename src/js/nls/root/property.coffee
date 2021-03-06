define
  actions:
    search:                           "Search"
    geolocate:                        "Geolocate Me"
    new_property:                     "New Property"
    setup_property:                   "Setup Property"
    go_to_network:                    "Go to network"
    # add_to_start:                     "Add a property to get started"
    add_a_property:                   "Add a property"
    share_property:                   "Share property"
    join_or_create_to_start:          "Join or create a property to get started"
    join_property_at:      (title) -> "Create your lease at <em>#{_.escape(title)}</em>"
  menu:                                 
    dashboard:                        "Dashboard"
    day_to_day:                       "Day to Day"
    reports:                          "Reports"
    income:                           "Income"
    expenses:                         "Expenses"
    other:                            "Other"
    actions:                          "Actions"
    building:                         "Building"
    tenants:                          "Tenants" # "Tenant Directory"
    message_board:                    "Message Board"
    tasks:                            "Tasks"
    listings:                         "Listings"
    applicants:                       "Applicants"
    add_lease:                        "Add lease"
    add_tenants:                      "Add tenants"
    add_income:                       "Add income"
    add_expense:                      "Add expense"
    add_post:                         "Add a post"
    add_task:                         "Add a task"
    add_listing:                      "Add listing"
    occupancy:                        "Occupancy"
    incomes:                          "Income"
    expenses:                         "Expenses"
    cash_transactions:                "Cash Transactions"
    lease_history:                    "Lease History"
    photos:                           "Photos"
    edit_property:                    "Edit Property"
    edit_photos:                      "Edit Photos"
    edit_units:                       "Edit Units"
    edit_managers:                    "Edit Managers"
    managers:                         "Managers"
    view_public:                      "See Public View"
    view_tenant:                      "See Tenant View"
  activity:
    new_property: ->          
                                      titles = [
                                        "Saying hi to everyone.",
                                        "We're in the neighbourhood!",
                                        "Wanted to introduce ourselves!",
                                        "We just joined CleverTower."
                                      ]
                                      titles[Math.floor(Math.random() * titles.length)]

    added_photos:          (count) -> "We added " + if count is 1 then "a new photo." else "#{count} photos."
  listing:
    public:                           "Display Public"
    public_info:                      "Whether this property will appear in search results"
    approx:                           "Display Address"
    approx_info:                      "Whether the exact address or a representative area is shown."
  network:
    edit:                             "Edit network"
    setup:                            "Set up network"
    unique_name:                      "Unique username"
    claim_username:                   "Claim your network's unique username."
    claim_domain:                     "Claim your network's unique domain name."
    find_username:                    "Enter the unique username of the network you wish to join."
    find_domain:                      "Enter the unique domain name of the network you wish to join."
    must_be_done:                      """
                                      Before you can begin managing properties to CleverTower, you must create your network.
                                      Only people who you invite to your network can edit properties.
                                      You can change these settings at any time.
                                      """
    give_network_a_title:             "Give your network a title."
    can_be_anything:                  "Can be anything you like."
  structure:                          
    vacancies:                        "Vacancies"
    units_control:                    "Units Control"
  form:                                                   
    marketing:                        "Marketing"
    contact:                          "Contact"
    building:                         "Building"
    features:                         "Features"
    amenities:                        "Amenities"
    included:                         "Included"
  search:
    map_instructions_mgr:             "Find the building on the map. If the building is on CleverTower, you'll have the chance to manage it."
    map_instructions_tnt:             "Find your building on the map. If the building is on CleverTower, you'll have the chance to join."
    awaiting_search:                  "Awaiting search."
    no_property_results:              "No nearby buildings on CleverTower."
    no_network_results:               "No networks match that name."
    private_property:                 "Properties set to private will not appear."
    private_network:                  "Maybe the network is set to private?"
  tenant_empty:
    activity:                         "This property has not had any activity."
    photos:                           "This property has not added any photos."
    listings:                         "There are no advertised vacancies in the property."
  empty:                            
    properties:                       "You don't have any properties yet."
    units:                            "You don't have any units yet."
    leases:                           "You don't have any leases yet."
    photos:                           "You don't have any photos yet."
    building:                         "You haven't joined a property yet. Join your current building, or explore and find a new one."
  fields:                             
    description:                      "Description"
    photos:                           "Photos"
    property_type:                                           
      label:                          "Property Type"
      condo:                          "Condo"
      apartment:                      "Apartment"
    year:                             "Year"
    mls:                              "MLS"
    air_conditioning:                 "Air conditioning"
    back_yard:                        "Back yard"
    balcony:                          "Balcony"
    cats_allowed:                     "Cats allowed"
    concierge:                        "Concierge"
    dogs_allowed:                     "Dogs allowed"
    doorman:                          "Doorman"
    elevator:                         "Elevator"
    exposed_brick:                    "Exposed brick"
    fireplace:                        "Fireplace"
    front_yard:                       "Front yard"
    gym:                              "Gym"
    laundry:                          "Laundry"
    indoor_parking:                   "Indoor parking"
    outdoor_parking:                  "Outdoor parking"
    park:                             "Park"
    pool:                             "Pool"
    sauna:                            "Sauna"
    wheelchair:                       "Wheelchair access"
    electricity:                      "Electricity"
    furniture:                        "Furniture"
    gas:                              "Gas"
    heat:                             "Heat"
    hot_water:                        "Hot water"
  
  errors:
    name_reserved:                    "That name is reserved by CleverTower. Please choose another."
    name_invalid:                     "You did not enter a valid name. Make sure there are only lowercase letters."
    name_too_short:                   "The name must be at least four letters long"
    name_too_short:                   "The name cannot be longer than 31 characters."
    name_missing:                     "You must enter a name."
    name_taken:             (id) ->   """
                                      <p>This name has been taken by an existing network.</p>
                                      <p class="text-left">
                                        <a href="/networks/#{_.escape(id)}" class="btn btn-warning">View network</a>
                                      </p>
                                      """
    network_not_set:                  "You have not joined a network yet."
    invalid_address:                  "You must add an address."
    insufficient_data:                "We were unable to determine your address."
    no_geolocaiton:                   "Your browser doesn't support geolocation."
    taken_by_network:       (id) ->   "Your group already has <a href='/properties/#{_.escape(id)}'>a property</a> at this address."
    taken_by_user:          (id) ->   "You already have <a href='/properties/#{_.escape(id)}'>a property</a> at this address."
    "success/error was not called":   "<strong>D'oh!</strong> Something went wrong. Please try again."
    access_denied:                    "You do not have access to the property."
    missing:                          "You must select a property."
    name_missing:                     "A title is required."