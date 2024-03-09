# auth0.com provider definition.
provider "auth0" {
  domain        = data.external.auth0Credentials.result["domain"]
  client_id     = data.external.auth0Credentials.result["api_id"]
  client_secret = data.external.auth0Credentials.result["api_secret"]
}

# auth0.com credentials definition.
data "external" "auth0Credentials" {
  program = [ "./auth0Credentials.sh"]
}

# auth0.com branding definition.
resource "auth0_branding" "default" {
  logo_url = "https://www.akamai.com/site/pt/images/logo/akamai-logo1.svg"

  colors {
    primary         = "#019bde"
    page_background = "#f1f1f1"
  }

  depends_on = [ data.external.auth0Credentials ]
}

# auth0.com prompt text definition.
resource "auth0_prompt_custom_text" "default" {
  prompt = "login"
  language = "en"
  body = jsonencode(
    {
      "login" : {
        "pageTitle": "Log in to the $${clientName}",
        "title": "Welcome",
        "description": "Log in to the $${clientName}",
        "separatorText": "Or",
        "buttonText": "Continue",
        "federatedConnectionButtonText": "Continue with $${connectionName}",
        "footerLinkText": "Sign up",
        "signupActionLinkText": "$${footerLinkText}",
        "footerText": "Don't have an account?",
        "signupActionText": "$${footerText}",
        "forgotPasswordText": "Forgot password?",
        "passwordPlaceholder": "Password",
        "usernamePlaceholder": "Username or email address",
        "emailPlaceholder": "Email address",
        "editEmailText": "Edit",
        "alertListTitle": "Alerts",
        "invitationTitle": "You've Been Invited!",
        "invitationDescription": "Log in to accept $${inviterName}'s invitation to join $${companyName} on $${clientName}.",
        "logoAltText": "$${companyName}",
        "showPasswordText": "Show password",
        "hidePasswordText": "Hide password",
        "wrong-credentials": "Wrong username or password",
        "invalid-email-format": "Email is not valid.",
        "wrong-email-credentials": "Wrong email or password",
        "custom-script-error-code": "Something went wrong, please try again later.",
        "auth0-users-validation": "Something went wrong, please try again later",
        "authentication-failure": "We are sorry, something went wrong when attempting to login",
        "invalid-connection": "Invalid connection",
        "ip-blocked": "We have detected suspicious login behavior and further attempts will be blocked. Please contact the administrator.",
        "no-db-connection": "Invalid connection",
        "password-breached": "We have detected a potential security issue with this account. To protect your account, we have prevented this login. Please reset your password to proceed.",
        "user-blocked": "Your account has been blocked after multiple consecutive login attempts.",
        "same-user-login": "Too many attempts for this user. Please wait and try again later.",
        "no-email": "Please enter an email address",
        "no-password": "Password is required",
        "no-username": "Username is required"
      }
    }
  )

  depends_on = [ data.external.auth0Credentials ]
}

# Updates the auth0.com client with the allowed URLs after the LKE stack provisioning.
resource "null_resource" "updateAuth0AllowedUrls" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    quiet   = true
    command = "./auth0AllowedUrls.sh"
  }

  depends_on = [ null_resource.applyLkeStack ]
}