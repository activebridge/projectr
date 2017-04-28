FactoryGirl.define do
  factory :pull_request, class: Hash do
    sequence(:id) { |n| n }
    base { { 'ref' => 'master' } }
    head { { 'ref' => 'head', 'sha' => 'sha' } }
    state 'open'
    number 2
    title 'title'

    initialize_with { attributes.stringify_keys }
  end
end
