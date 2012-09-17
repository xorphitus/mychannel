class Trac < ActiveRecord::Base
  belongs_to :topic
  attr_accessible :action, :order, :post_content, :pre_content, :target

  [:topic_id, :action, :target].each do |i|
    validates i, presence: true
  end
  validates :pre_content, length: {maximum: 100}
  validates :post_content, length: {maximum: 100}
end
