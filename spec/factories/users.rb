FactoryGirl.define do
  factory :user do
    sequence(:fb_id) { |n| n * 1000 }
    sequence(:fb_name) { |n| "Name#{n} Surname#{n}" }
    fb_pic 'https://upload.wikimedia.org/wikipedia/commons/a/ab/Lolcat_in_folder.jpg'
  end
end
