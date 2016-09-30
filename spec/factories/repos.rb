FactoryGirl.define do
  factory :repo do
    user
    sequence(:name) { |n| "repo#{n}" }
    sequence(:ssh) { |n| "git@github.com:repo#{n}.git" }
  end
end
