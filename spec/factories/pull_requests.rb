FactoryGirl.define do
  factory :pull_request, class: Hash do
    base { { 'ref' => 'master' } }
    head { { 'ref' => 'head', 'sha' => 'sha' } }
    state 'open'
    number 2

    initialize_with { attributes.stringify_keys }
  end
end
