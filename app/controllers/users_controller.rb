class UsersController < ApplicationController
  skip_before_filter :logged_in?, :only => [:new, :create]
  def index
    @links = [{:link => elements_path, :text => "Elements"}]
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
