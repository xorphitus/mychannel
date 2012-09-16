class Topic < ActiveRecord::Base
  belongs_to :channel
  attr_accessible :name, :order, :target, :target_text, :tracs_attributes
  has_many :tracs, dependent: :destroy

  accepts_nested_attributes_for :tracs, allow_destroy: :true, reject_if: proc { |attrs| attrs.all? { |k, v| v.blank? } }

  [:channel_id, :name, :order, :target].each do |i|
    validates i, presence: true
  end
  validates :name, length: {maximum: 20}
  validates :target_text, length: {maximum: 100}
end
