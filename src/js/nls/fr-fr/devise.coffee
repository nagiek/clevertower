define
  actions:
    signin:                         "Se connecter"
    signup:                         "Inscrivez-vous"
    logout:                         "Déconnexion"
    login:                          "Connecter"
    forgot_your_password:           "Mot de passe oublié?"
    missing_confirmation:           "Vous n'avez pas reçu les instructions de confirmation?"
    missing_unlock:                 "Vous n'avez pas reçu les instructions de déverrouillage?"
    sign_in_with:                   "Connectez-vous avec %{fournisseur}"
    change_password:                "Changer mon mot de passe"
    confirm_account:                "Confirmer mon compte"
    resend_unlock_instructions:     "Renvoyer aux instructions de déverrouillage"
    unlock_account:                 "Déverrouiller mon compte"
  form:
    structure:
      email:                        "Courriel"
      password:                     "Mot de passe"
      edit_resource:                "Modifier %{resource}"
      password_change_hint:         "Laissez vide si vous ne voulez pas le changer"
      password_current_hint:        "Nous avons besoin de votre mot de passe actuel pour confirmer vos modifications"
      cancel_account:               "Annuler mon compte"
      cancel_account_instructions:  "Malheureux? %{href}"
      new_password:                 "Nouveau mot de passe"
      new_password_confirm:         "Confirmer nouveau mot de passe"
      send_instructions:            "Envoyer des instructions"
    errors:                         
      invalid_login:                "Invalid email ou mot de passe. S'il vous plaît essayez de nouveau."
  mailer:
    general:
      greeting:                     "Bonjour %{name}"
      welcome:                      "Bienvenue %{person}!"
    reset_password:                 
      explanation:                  "Quelqu'un a demandé un lien pour changer votre mot de passe. Vous pouvez le faire via le lien ci-dessous."
      ignore_if:                    "Si vous n'avez pas demandé cela, s'il vous plaît ignorer ce message."
      reassurance:                  "Votre mot de passe ne changera pas jusqu'à ce que vous ouvrir le lien ci-dessus et en créer un nouveau."
    confirm:                        
      explanation:                  "Vous pouvez confirmer votre compte de messagerie via le lien ci-dessous:"
    unlock:                         
      explanation:                  "Votre compte a été bloqué en raison d'un nombre excessif de signe échoué dans leurs tentatives."
      link_explanation:             "Cliquez sur le lien ci-dessous pour déverrouiller votre compte:"