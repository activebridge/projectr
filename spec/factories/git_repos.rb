FactoryGirl.define do
  factory :git_repo, class: Hash do
    sequence(:ssh_url) { |n| "git@github.com:project#{n}.git" }
    default_branch 'master'

    initialize_with { attributes.stringify_keys }
  end
end
