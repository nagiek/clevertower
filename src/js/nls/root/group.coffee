define
  actions:
    accept:             "accept"
    ignore:             "ignore"
    reject:             "reject"
    invite_to_network:  "Invite to this network"
    apply:
      property:         "Apply to this property"
      listing:          "Apply to this listing"
    live:
      property:         "Join this property"
  tenant:
    do_you_live_here:   "Do you live here?"
    empty: 
      index:            "There are no tenants in your network."
      in_property:      "There are no tenants in the property."
    notices:
      create:           'Tenants added to lease'
      update:           'Lease was successfully updated with new tenants.'
  manager:
    instructions:       """
                        New members will be allowed to post. They will not be able to make
                        any changes to this blog's settings, unless you promote them to an admin.
                        """
    deleted_if_empty:   "This blog will be automatically deleted if all of its members leave."
    delete_network:     "Delete network"
    notices:
      update:           'New managers were successfully added.'
  fields:
    status:
      label:            "Status"
      active:           "Active"
      invited:          "Invited"
      pending:          "Pending"
    admin:              "admin"
  form:
    instructions:       """
                        To invite others to contribute to this blog, submit their email address below. 
                        They'll receive an email with instructions to join this blog and register if they're not a CleverTower user yet.
                        """
  errors:
    unique_tenant:       "This user has already been added."