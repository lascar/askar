require 'rails_helper'

RSpec.describe UsersController, :type => :controller do
  describe 'GET #index' do
    context 'when no authenticate' do
      it 'redirect to login' do
        get :index
        expect(response).to redirect_to '/log_in'
      end
    end

    #context 'when authenticate', js: true do
    #  it 'serves the layout' do
    #    user = create(:valid_user)
    #    login_in(user)
    #    get :index
    #    expect(response).to_not redirect_to '/log_in'
    #  end
    #end
  end
end
