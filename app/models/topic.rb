class Topic < ActiveRecord::Base
  belongs_to :channel
  attr_accessible :name, :order, :target, :target_text

  [:channel_id, :name, :order, :target].each do |i|
    validates i, presence: true
  end
  validates :name, length: {maximum: 20}
  validates :target_text, length: {maximum: 100}
end
