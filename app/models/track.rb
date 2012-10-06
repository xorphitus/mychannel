class Track < ActiveRecord::Base
  belongs_to :topic
  attr_accessible :action, :order, :post_content, :pre_content, :target

  validates :topic_id, presence: true
  validates :action, presence: true
  validates :target, presence: true
  validates :pre_content, length: {maximum: 100}
  validates :post_content, length: {maximum: 100}
end
