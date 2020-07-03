class ConfirmedUserGuard < Clearance::SignInGuard
  def call
    if user_confirmed?
      next_guard
    else
      failure "Please confirm your email address"
    end
  end

  def user_confirmed?
    signed_in? && current_user.confirmed?
  end
end
