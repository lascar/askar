class UsersController < ApplicationController
  layout "application_before_login"
  skip_before_filter :logged_in?, :only => [:new, :create]
  def index
    redirect_to elements_path
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to :action => :index, :notice => "Signed up!"
    else
      render "new"
    end
  end

  private
  def user_params
    params.require(:user).require(:password)
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
