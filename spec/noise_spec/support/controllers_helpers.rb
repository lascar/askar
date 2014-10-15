module HelperMethods
  # Helpers for controller specs
  module Controller
    def login_as(username, role = 'reporter')
      session[:user_id] = username
      session[:user_role] = role
    end

    def expect_login_redirect
      expect(response).to redirect_to('/en/login')
    end
  end
end
