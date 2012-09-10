class Channel < ActiveRecord::Base
  belongs_to :user
  attr_accessible :description, :name, :publish_flag
  has_many :topics

  [:topic_id, :name, :publish_flag].each do |i|
    validates i, presence: true
  end
  validates :name, length: {maximum: 20}
  validates :description, length: {maximum: 100}
end
