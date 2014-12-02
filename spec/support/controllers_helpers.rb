module HelperMethods
  # Helpers for controller specs
  module Controller
    def login_in(user)
      visit '/log_in'
      fill_in 'email', :with => user.email
      fill_in 'password', :with => user.password
      click_button 'login'
    end
  end
end
