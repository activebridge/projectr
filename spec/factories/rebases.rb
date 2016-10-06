FactoryGirl.define do
  factory :rebase do
    repo
    base { FFaker::Internet.domain_word }
    head { FFaker::Internet.domain_word }
    sha { FFaker::IdentificationMX.rfc }
    title { FFaker::CheesyLingo.title }
    state 'close'
    status 'failure'
    number 5
    sequence(:github_id) { |n| n }
  end
end
