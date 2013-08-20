# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email "pascal.carrie@gmail.com"
    password "toto45"
    password_confirmation "toto45"
  end
end
