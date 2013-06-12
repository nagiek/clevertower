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
                        New managers will be allowed to create properties, listings and invite tenants.
                        """
    deleted_if_empty:   "This network will be automatically deleted if all of the managers leave."
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
                        To invite others to this network, enter their email address below. 
                        They will receive an email with instructions to join this network and register 
                        if they are not on CleverTower yet.
                        """
  errors:
    unique_tenant:       "This user has already been added."