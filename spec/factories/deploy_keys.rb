FactoryGirl.define do
  factory :deploy_key, class: Hash do
    sequence(:key) { |n| "ssh-rsa #{n}" }
    title 'ProjectR'

    initialize_with { attributes.stringify_keys }
  end
end
