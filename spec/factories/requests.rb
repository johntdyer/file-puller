# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :request do
    query "MyText"
    email "MyString"
    start_time "2014-02-26 10:03:55"
    end_time "2014-02-26 10:03:55"
    results "MyString"
  end
end
