(function() {

  define({
    headers: {
      add_lease: "Add Lease"
    },
    actions: {
      add_tenants: "add tenants to lease",
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
      starting_this_month: "Starting This Month",
      starting_next_month: "Starting Next Month",
      july_to_june: "July 1st to June 30th"
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
      unit_missing: "You must enter a unit",
      dates_missing: "You must enter a start and end date",
      dates_incorrect: "The start date cannot be after the end date",
      existing_lease: function(lease_url, unit_url, unit) {
        return "There is <a href='" + (_.escape(lease_url)) + "'>another lease</a> on <a href='" + (_.escape(unit_url)) + "'>unit " + (_.escape(unit)) + "</a> for those dates.";
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
