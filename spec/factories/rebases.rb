FactoryGirl.define do
  factory :rebase do
    repo
    base 'master'
    head 'head'
    sha 'sha'
    state 'open'
    status 'success'
    number 2
  end
end
