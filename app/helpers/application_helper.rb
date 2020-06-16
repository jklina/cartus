module ApplicationHelper
  def render_if_user_owner
    if @user == current_user
      yield
    end
  end
end
