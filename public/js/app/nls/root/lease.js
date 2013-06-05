(function() {
  define({
    headers: {
      add_lease: "Add Lease",
      edit_lease: "Edit Lease",
      extend_lease: "Extend Lease"
    },
    actions: {
      add_tenants: "add tenants to lease",
      add_new_lease: "Add a new lease",
      extend: "extend lease",
      "new": "new lease"
    },
    attributes: {
      starting: "Starting",
      ending: "Ending",
      lease_on_unit: "Lease on Unit",
      rent_this_month: "Rent this month"
    },
    dates: {
      this_month: "This Month",
      next_month: "Next Month",
      july: "July 1st",
      active: "active",
      inactive: "inactive"
    },
    rent: {
      first_month_paid: "First Month Paid",
      last_month_paid: "Last Month Paid",
      checks_received: "Checks Received"
    },
    collection: {
      empty: "You don't have any leases in the property yet."
    },
    tenants: {
      empty: "You haven't added any tenants to the lease yet."
    },
    errors: {
      no_title: "You must enter a title for the unit",
      unit_missing: "You must enter a unit",
      dates_missing: "You must enter a start and end date",
      dates_incorrect: "The start date cannot be after the end date",
      tenants_incorrect: "You did not enter a valid email",
      overlapping_dates: function(lease_url) {
        return "There is <a href='" + (_.escape(lease_url)) + "'>another lease</a> on that unit which conflicts with these dates.";
      },
      existing_payments: 'Payments have already been paid past the end date. Adjust the payment schedule to make this change.',
      insufficient_time: function(paid_incomes_count, months) {
        return "You have already received " + (_.escape(paid_incomes_count)) + " payments on this lease, and the new dates would only have " + (_.escape(months)) + " payments. Please check your dates.";
      }
    },
    fields: {
      rent: "Monthly Fee",
      expenses: "Expenses",
      payments: "Payments",
      start_date: "Start Date",
      end_date: "End Date",
      security_deposit: "Security Deposit",
      keys: "Keys",
      parking_fee: "Monthly Fee",
      parking_space: "Space",
      garage_remotes: "Remotes"
    },
    form: {
      extend_instructions: "This will create a new lease based on the old one.",
      enter_emails: "Enter the email addresses of the people you wish to add.",
      to_existing: "To existing lease on unit",
      dates: "Dates",
      rent: "Rent",
      parking: "Parking",
      deposit: "Deposit",
      tenants: "Tenants"
    }
  });

}).call(this);
