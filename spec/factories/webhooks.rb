FactoryGirl.define do
  factory :webhook, class: Hash do
    type 'Repository'
    name 'web'
    events %w(push pull_request)
    config { { 'url' => 'http://3deec0f4.ngrok.io/webhook' } }

    initialize_with { attributes.stringify_keys }
  end
end
