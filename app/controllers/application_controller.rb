# for yet just in charge of filter for authentication
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user
  before_action :user_logged?
  
  private
  def user_logged?
    unless current_user
      redirect_to '/log_in'
    end
  end

  def current_user
    user = session[:user_id]
    @current_user ||= User.find(user) if user
  end
end
