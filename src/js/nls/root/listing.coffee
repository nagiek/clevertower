define
  headers:
    add_listing:                      "Add Listing"
    edit_listing:                     "Edit Listing"
    extend_listing:                   "Extend Listing"
  actions:            
    add_listing:                      "Add Listing"
    apply:                            "Apply"
    apply_to:                         "Apply to"
    withdraw:                         "withdraw"
    promote:                          "Promote"
  attributes:           
    applied:                          "Applied"
    starting:                         "Starting"
    ending:                           "Ending"
    listing_on_unit:                  "Listing on Unit"
    rent_this_month:                  "Rent this month"
  display:            
    map:                              "Map"
    list:                             "List"
    photo:                            "Photo"
  map:
    redo_search:                      "Redo search"
    redo_search_in_area:              "Redo search in this area"
  dates:            
    starting_this_month:              "Starting This Month"
    starting_next_month:              "Starting Next Month"
    july_to_june:                     "July 1st to June 30th"
    active:                           "active"
    inactive:                         "inactive"
  listings:
    empty:            
      network:                        "You don't have any listings in the network yet."
      property:                       "You don't have any listings in the property yet."
      self:                           "You haven't created a listing yet."
      index:                          "No one has posted any thing here yet."
  inquiries:            
    label:                            "Inquiries"
    chosen:                           "Chosen"
    empty:            
      listing:                        "No one has responded to the listing yet."
      network:                        "You don't have any listings in the network yet."
      property:                       "You don't have any listings in the property yet."
  errors:           
    unit_missing:                     "You must enter a unit"
    dates_missing:                    "You must enter a start and end date"
    dates_incorrect:                  "The start date cannot be after the end date"
    overlapping_dates:                (listing_url) -> "There is <a href='#{_.escape(listing_url)}'>another listing</a> on that unit which conflicts with these dates."
  fields:           
    title:                            "Headline"
    rent:                             "Rent"
    public:                           ["inactive", "public"]
  warnings:           
    accept_instructions:              "This will create a new lease and close the listing."
  form:           
    dates:                            "Dates"
    inquiry_tenants:                  "Other people who will live with you"
    comments:                         "Additional info"
    give_approximate_address:         "Approximate address"
    title_placeholders:               [
                                      "Great location, near the heart of downtown!"
                                      "Newly renovated kitchen makes this a dream."
                                      "Cozy studio for students/young professionals."
                                      ]
    title_help:                       "First thing shown to potential applicants. What makes your place special?"