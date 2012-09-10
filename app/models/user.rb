class User < ActiveRecord::Base
  attr_accessible :fb_id, :name
  has_many :channels

  validates :fb_id, {presence: true, uniqueness: true}
  validates :name, length: {maximum: 20}
end
