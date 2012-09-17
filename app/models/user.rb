class User < ActiveRecord::Base
  attr_accessible :fb_id, :name
  has_many :channels, dependent: :destroy

  validates :name, {presence: true, uniqueness: true, length: {maximum: 20}}
  validates :fb_id, {presence: true, uniqueness: true}
end
