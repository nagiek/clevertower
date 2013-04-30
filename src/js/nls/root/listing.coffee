define
  headers:
    add_listing:          "Add Listing"
    edit_listing:         "Edit Listing"
    extend_listing:       "Extend Listing"
  actions:
    apply:                "Apply"
    apply_to:             "Apply to"
    withdraw:             "withdraw"
  attributes:
    applied:              "Applied"
    starting:             "Starting"
    ending:               "Ending"
    listing_on_unit:      "Listing on Unit"
    rent_this_month:      "Rent this month"
  dates:
    starting_this_month:  "Starting This Month"
    starting_next_month:  "Starting Next Month"
    july_to_june:         "July 1st to June 30th"
    active:               "active"
    inactive:             "inactive"
  listings:
    empty:
      network:            "You don't have any listings in the network yet."
      property:           "You don't have any listings in the property yet."
  inquiries:
    label:                "Inquiries"
    chosen:               "Chosen"
    empty:
      listing:            "No one has responded to the listing yet."
      network:            "You don't have any listings in the network yet."
      property:           "You don't have any listings in the property yet."
  errors:
    unit_missing:         "You must enter a unit"
    dates_missing:        "You must enter a start and end date"
    dates_incorrect:      "The start date cannot be after the end date"
    overlapping_dates:    (listing_url) -> "There is <a href='#{_.escape(listing_url)}'>another listing</a> on that unit which conflicts with these dates."
  fields:
    title:                "Headline"
    rent:                 "Rent"
    public:               ["inactive", "public"]
  warnings:
    accept_instructions:  "This will create a new lease and close the listing."
  form:
    dates:                "Dates"
    inquiry_tenants:      "Other people who will live with you"
    comments:             "Additional info"
    title_placeholders:   [
                          "Great location, near the heart of downtown!"
                          "Newly renovated kitchen makes this a dream."
                          "Cozy studio for students/young professionals."
                          ]
    title_help:           "First thing shown to potential applicants. Specifics help!"
    unit_help:            "Only visible to managers."