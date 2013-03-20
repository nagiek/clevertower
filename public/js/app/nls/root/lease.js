(function() {

  define({
    actions: {
      add_tenants: "add tenants to lease",
      extend: "extend lease",
      "new": "New lease"
    },
    attributes: {
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
      first_month_paid: "First Month Rent Paid",
      last_month_paid: "Last Month Rent Paid",
      checks_received: "Checks Received"
    },
    form: {
      enter_emails: "Enter the email addresses of the people you wish to add."
    },
    errors: {
      dates: function(lease_url, unit_url, unit) {
        return "There is <a href='" + (_.escape(lease_url)) + "'>another lease</a> on <a href='" + (_.escape(unit_url)) + "'>unit " + (_.escape(unit)) + "</a> for those dates.";
      },
      existing_payments: 'Payments have already been paid past the end date. Adjust the payment schedule to make this change.',
      insufficient_time: function(paid_incomes_count, months) {
        return "You have already received " + (_.escape(paid_incomes_count)) + " payments on this lease, and the new dates would only have " + (_.escape(months)) + " payments. Please check your dates.";
      }
    },
    fields: {
      rent: "Rent",
      expenses: "Expenses",
      payments: "Payments",
      start_date: "Start Date",
      end_date: "End Date",
      security_deposit: "Security Deposit",
      keys: "Keys",
      parking_fee: "Parking Fee",
      parking_space: "Parking Space",
      garage_remotes: "Garage Remotes"
    },
    form: {
      to_existing: "To existing lease on unit",
      dates: "Dates",
      rent: "Rent",
      parking: "Parking",
      deposit: "Deposit"
    }
  });

}).call(this);
