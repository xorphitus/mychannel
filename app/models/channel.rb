# -*- coding: utf-8 -*-

class Channel < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :publish_flag, :description
  has_many :topics, dependent: :destroy

  validates :user_id, presence: true
  validates :name, presence: true, length: {maximum: 20}
  validates :description, length: {maximum: 100}

  def to_story(me)
    topic = self.topics.sample
    raise "Could not find any topics for channel_id = #{channel_id}" if topic.blank?

    contents = topic.to_story_contents(me)
    {metadata: {hash: contents.hash}, contents: contents}
  end
end
