class Channel < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :publish_flag, :description
  has_many :topics, dependent: :destroy

  validates :user_id, presence: true
  validates :name, presence: true, length: {maximum: 20}
  validates :description, length: {maximum: 100}
end
