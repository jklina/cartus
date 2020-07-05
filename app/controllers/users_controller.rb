class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    @posts = @user.posts.or(@user.posts_from_friends).order(created_at: :desc)
  end

  def create
    @user = User.new(user_params)
    @user.email_confirmation_token = Clearance::Token.new

    if @user.save!
      UserMailer.with(@user).registration_confirmation.deliver_later
      flash.notice = "Your profile has been created. Please confirm your email to login!"
      redirect_back_or sign_in_path
    else
      render template: "users/new"
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash.notice = "Your profile has been updated."
      redirect_to @user
    else
      flash.alert = "There was a problem saving your profile."
      render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :birthday, :gender, :email, :password)
  end
end
