define
  actions:
    add_tenants:          "add tenants to lease"
    extend:               "extend lease"
    new:                  "New lease"
  attributes:
    ending:               "Ending"
    lease_on_unit:        "Lease on Unit"
    rent_this_month:      "Rent this month"
  errors:
    messages:
      dates:              "There is <a href='%{lease_url}'>another lease</a> on <a href='%{unit_url}'>unit %{unit}</a> for those dates."
      existing_payments:  'Payments have already been paid past the end date. Adjust the payment schedule to make this change.'
      insufficient_time:  "You have already received %{paid_incomes_count} payments on this lease, and the new dates would only have %{months} payments. Please check your dates."
  fields:
    rent:                 "Rent"
    expenses:             "Expenses"
    payments:             "Payments"
    start_date:           "Start Date"
    end_date:             "End Date"
  form:
    to_existing:          "To existing lease on unit"
    dates:                "Dates"
    rent:                 "Rent"
    parking:              "Parking"
    deposit:              "Deposit"