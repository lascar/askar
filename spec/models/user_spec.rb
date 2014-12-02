require 'rails_helper'

RSpec.describe User, :type => :model do
  it "creates valid user" do
    user = create(:valid_user)
    expect(user).to be_valid
  end
  it "can not create user without email" do
    user = build(:no_email_user)
    expect(user).to_not be_valid
  end
  it "can not create user without password" do
    user = build(:no_password_user)
    expect(user).to_not be_valid
  end
  it "authenticates user with valid password" do
    user = create(:valid_user)
    auth = User.authenticate(user.email, user.password)
    expect(user).to eq(auth)
  end
  it "does not authenticate user with wrong password" do
    user = create(:valid_user)
    auth = User.authenticate(user.email, user.password.slice(0..2))
    expect(user).to_not eq(auth)
  end
end
