FactoryGirl.define do
  factory :user do
    name { FFaker::Name.name }
    email { FFaker::Internet.email }
    username { FFaker::Name.first_name }
    avatar 'MyString'
    token { SecureRandom.base64 }
    sequence(:github_id) { |n| n }
  end
end
