class User < ActiveRecord::Base
  attr_accessible :fb_id, :name
  has_many :channels, dependent: :destroy

  validates :fb_id, {presence: true, uniqueness: true}
  validates :name, {presence: true, uniqueness: true, length: {maximum: 20}}
end
