FactoryGirl.define do
  factory :admin_repo do
    sequence(:full_name) { |n| "ProjectR#{n}" }
    created_at { FFaker::Time.date }
  end
end
