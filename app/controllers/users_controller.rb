# user controller
class UsersController < ApplicationController
  skip_before_filter :logged_in?, :only => [:new, :create]
  def index
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
    params.require(:user).require(:email, :password, :password_confirmation)
  end
end
