class User < ApplicationRecord
  validates :fb_id, :fb_pic, :fb_name, presence: true
end
