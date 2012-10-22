# -*- coding: utf-8 -*-
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

  def self.select_topic_tree(channel_id)
    topics = Topic.where(channel_id: channel_id)
    raise "Could not find any topics for channel_id = #{channel_id}" if topics.blank?

    topic = topics.sample
    # productionのMySQLだと想定の順序になってくれないのでひとまずidでorder
    tracks = topic.tracks.order(:id)
    raise "Could not find any tracks for channel_id = #{channel_id}, topic_id = #{topic.id}" if tracks.blank?

    [topic, tracks]
  end

  def self.aquire_fb_target(me, topic)
    me.send(topic.target.to_sym)
      .reject { |fb_target| %w(home feed).include?(topic.target) && fb_target.message.blank? }
      .sample
  end

  def self.to_story_contents(fb_target, tracks)
    inherited_value = nil

    tracks.map do |track|
      if track.target == "prev"
        fb_attribute = inherited_value
      else
        fb_attribute = fb_target
        track.target.split(".").each { |attribute_name| fb_attribute = fb_attribute.send(attribute_name.to_sym) }
        inherited_value = fb_attribute
      end

      json_elem, inherited_value = track.to_json_element(fb_attribute, inherited_value)
      json_elem
    end
  end

  private_class_method :select_topic_tree, :aquire_fb_target, :to_story_contents

  def self.to_story(me, channel_id)
    topic, tracks = select_topic_tree(channel_id)

    fb_target = aquire_fb_target(me, topic)
    return [text: "もっとFacebook使ってリア充になって欲しいお"] if fb_target.blank?

    contents = to_story_contents(fb_target, tracks)
    {metadata: {hash: contents.hash}, contents: contents}
  end
end
