FactoryGirl.define do
  factory :valid_user, class: 'User' do
    email "john@askar.org"
    password  "fake"
  end
  factory :no_email_user, class: 'User' do
    email ""
    password  "fake"
  end
  factory :no_password_user, class: 'User' do
    email "john@askar.org"
    password  ""
  end
end
