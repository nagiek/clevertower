define
  actions:
    signin:                         "Sign in"
    signup:                         "Sign up"
    logout:                         "Logout"
    login:                          "Login"
    forgot_your_password:           "Forgot your password?"
    missing_confirmation:           "Didn't receive confirmation instructions?"
    missing_unlock:                 "Didn't receive unlock instructions?"
    sign_in_with:                   "Sign in with %{provider}"
    change_password:                "Change my password"
    confirm_account:                "Confirm my account"
    resend_unlock_instructions:     "Resend unlock instructions"
    unlock_account:                 "Unlock my account"
  form:
    structure:
      email:                        "Email"
      password:                     "Password"
      edit_resource:                "Edit %{resource}"
      password_change_hint:         "Leave blank if you don't want to change it"
      password_current_hint:        "We need your current password to confirm your changes"
      cancel_account:               "Cancel my account"
      cancel_account_instructions:  "Unhappy? %{href}"
      new_password:                 "New password"
      new_password_confirm:         "Confirm new password"
      send_instructions:            "Send instructions"
    errors:
      invalid_login:                "Invalid email or password. Please try again."
  mailer:
    general:
      greeting:                     "Hello %{name}"
      welcome:                      "Welcome %{person}!"
    reset_password:                 
      explanation:                  "Someone has requested a link to change your password. You can do this through the link below."
      ignore_if:                    "If you didn't request this, please ignore this email."
      reassurance:                  "Your password won't change until you access the link above and create a new one."
    confirm:                        
      explanation:                  "You can confirm your account email through the link below:"
    unlock:                         
      explanation:                  "Your account has been locked due to an excessive number of unsuccessful sign in attempts."
      link_explanation:             "Click the link below to unlock your account:"