class Topic < ActiveRecord::Base
  belongs_to :channel
  attr_accessible :name, :order, :target, :target_text, :tracks_attributes
  has_many :tracks, dependent: :destroy

  accepts_nested_attributes_for :tracks, allow_destroy: :true, reject_if: proc { |attrs| attrs.all? { |k, v| v.blank? } }

  validates :channel_id, presence: true
  validates :name, presence: true, length: {maximum: 20}
  validates :order, presence: true
  validates :target, presence: true
  validates :target_text, length: {maximum: 100}
end
