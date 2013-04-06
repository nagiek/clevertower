define
  headers:
    home:                 "Home"
    search:               "Search"
    operations:           "Operations"
  classes:                
    lease:                "lease"
    Lease:                "Lease"
    Leases:               "Leases"
    Network:              "Network"
    Unit:                 "Unit"
    Tenant:               "Tenant"
    unit:                 "unit"
    units:                "units"
    Units:                "Units"
    tasks:                "tasks"
    finances:             "finances"
  actions:                
    go:                   "Go"
    show:                 "Show"
    destroy:              "Destroy"
    upload:               "Upload"
    remove:               "remove"
    delete:               "Delete"
    submit:               "Submit"
    next:                 "Next"
    cancel:               "Cancel"
    close:                "Close"
    save:                 "Save"
    update:               "Update"
    back:                 "Back"
    edit:                 "Edit"
    undo:                 "Undo"
    confirm:              "Are you sure?"
    add_more:             "Add more"
    add_another:          "Add another"
    add_files:            "Add files"
    add_photos:           "Add photos"
    choose_file:          "Choose file"
    choose_photo:         "Choose photo"
    add_x_more:           "Add <strong>x</strong> more"
    changes_saved:        "Changes Saved."
  dates:
    moment_format:        "MM/DD/YYYY" # Convenience reference to moment().format("L")
    datepicker_format:    "mm/dd/yyyy" # Same as above, but for datepicker widget
    per_month:            "Per month"
    date:                 "Date"
    day:                  "Day"
    month:                "Month"
    year:                 "Year"
    months:
      short:               ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
      
  notifications:
    img:                  "Notification Image"
    empty:                "No new notifications"
    # title:
    #   lease_invitation:   "Lease Invitation"
    #   lease_application:  "Lease Application"
    #   tenant_application: "Tenant Application"
    text:
      lease_invitation:   (person) -> "You have been invited to a lease at <strong>#{_.escape(property)}</strong>"
      lease_application:  (person, property) -> "<strong>#{_.escape(person)}</strong> has applied to join <strong>#{_.escape(property)}</strong>"
      tenant_application: (person, property) -> "<strong>#{_.escape(person)}</strong> has applied to join <strong>#{_.escape(property)}</strong>"
  status:
    unsaved:              "Unsaved"
    vacant:               "Vacant"
    pending:              "Pending"
    confirmed:            "Confirmed"
  prepositions:           
    of:                   "of"
    eg:                   "E.g., "
  verbs:             
    loading:              "Loading"
  nouns:             
    link:                 "link"
  order:
    first:                "First"
    last:                 "Last"
  adjectives:
    unsaved:              "Unsaved"
    all:                  "All"
    private:              "Private"
    landlord_only:        "Landlord Only"
  form:                   
    title:                "Title"
    info:                 "Info"
    required:             "Required"
    comma_separated:      "Enter a comma-separated list of email addresses."
    select:               
      select_value:       "- Select a value -"
      numeric:            "Numeric (1 ➡ 2)"
      alphabetical:       "Alpha (A ➡ B)"
  warnings:               
    no_undo:              "This action cannot be undone."
  errors:                 
    bad_save:             "Something went wrong. Changes were not saved."
    access_denied:        "Access denied"
    no_permission:        "You do not have permission to do that."
    unknown:              "An unknown error has occured."
      