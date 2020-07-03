Clearance.configure do |config|
  config.routes = false
  config.mailer_sender = "reply@example.com"
  config.rotate_csrf_on_sign_in = true
  config.redirect_url = "/timeline"
  config.sign_in_guards = [ConfirmedUserGuard]
end
