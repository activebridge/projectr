FactoryGirl.define do
  factory :repo do
    user
    name { FFaker::Name.name.parameterize }
    ssh "git@github.com:#{FFaker::Name.name.parameterize}.git"
  end
end
