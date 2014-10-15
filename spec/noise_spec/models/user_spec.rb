require 'spec_helper'

describe User do
  let(:user) {'hola.com/username'}
  let(:pass) {'password'}
  let(:authorization_code) {'authorization_code'}
  let(:token) {double}
  let(:password) {double(get_token: token)}
  let(:client) {double(password: password)}

  describe "#has_permission?" do
    it "checks the permissions for the users role" do
      user = User.new('some_name', 'editor')
      user.has_permission?(:manage_pages).should be_true
      user.has_permission?(:admin).should be_false
    end
  end

  describe ".grant" do
    context 'maintenance user' do
      before(:each) do
        @back_auth_config = AUTHORIZATION_CONFIG
        Object.const_redef(:AUTHORIZATION_CONFIG,
                           maintenance_username: 'maintenance_username',
                           maintenance_password: 'maintenance_password')
      end

      after(:each) do
        Object.const_redef(:AUTHORIZATION_CONFIG, @back_auth_config)
      end

      it 'should not connect to remote server when maintenance credentials are given' do
        OAuth2::Client.should_not_receive(:new)

        User.grant('maintenance_username',
                   'maintenance_password')
      end

      it 'should return valid grant for the maintenance user' do
        expect(User.grant('maintenance_username',
                          'maintenance_password')).to eql({id: 'maintenance_username',
                                                           role: 'admin'})
      end
    end

    context 'real user' do
      let(:response) { double(parsed: {'sub' => "myid@carbon.super",
                                       'http://wso2.org/claims/role' => "other_role,another_role"}) }
      before(:each) do
        OAuth2::Client.stub(:new).and_return(client)
        password.stub(:get_token).with(user, pass, scope: 'openid').and_return(token)
        token.stub(:get).with('/oauth2/userinfo?schema=openid').and_return(response)
      end

      it 'should return nil for wrong authentication' do
        password.stub(:get_token).and_raise

        expect(User.grant(user, pass)).to be_nil
      end

      it 'should return the parsed data for correct authentication' do
        back_publish_config = PUBLISH_CONFIG
        Object.const_redef(:PUBLISH_CONFIG, publication_name: 'hello-canada')
        id = 'myid'
        role = 'myrole'

        response = double(parsed: {'sub' => "#{id}@carbon.super",
                                   'http://wso2.org/claims/role' => "other_role,Internal/hellocanada_webcms_#{role}"})
        token.stub(:get).and_return(response)

        expect(User.grant(user, pass)).to eql({id: id, role: role})
        Object.const_redef(:PUBLISH_CONFIG, back_publish_config)
      end

      it 'sets default role when none is given' do
        grant = User.grant(user, pass)
        expect(grant[:role]).to eql(User::DEFAULT_ROLE)
      end

      it 'adds hola.com to the grant request if the username does not have it' do
        other_username = 'other_username'

        password.should_receive(:get_token).with('hola.com/other_username', pass, scope: 'openid').and_return(token)

        User.grant(other_username, pass)
      end

      it 'does not add hola.com to the grant request if the username already have it' do
        password.should_receive(:get_token).with(user, pass, scope: 'openid').and_return(token)

        User.grant(user, pass)
      end


      it 'removes hola.com from the returned username' do
        response = double(parsed: {'sub' => "#{user}@carbon.super",
                                       'http://wso2.org/claims/role' => "other_role,another_role"})

        token.stub(:get).and_return(response)

        grant = User.grant(user, pass)
        expect(grant[:id]).to_not include('hola.com')
      end
    end
  end
end
