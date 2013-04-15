(function() {

  define({
    actions: {
      accept: "accept",
      reject: "reject"
    },
    index: {
      empty: "There are no tenants in your network."
    },
    in_property: {
      empty: "There are no tenants in the property."
    },
    notices: {
      create: 'Tenants added to lease',
      update: 'Lease was successfully updated with new tenants.'
    },
    fields: {
      status: {
        active: "Active",
        invited: "Invited",
        pending: "Pending"
      }
    },
    errors: {
      unique_tenant: "This user has already been added."
    }
  });

}).call(this);
