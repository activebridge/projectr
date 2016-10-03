FactoryGirl.define do
  factory :admin_repo do
    sequence(:full_name) { |n| "projectr#{n}" }
    created_at { FFaker::Time.date }
  end
end
