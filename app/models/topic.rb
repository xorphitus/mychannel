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

  def to_story_contents(me)
    fb_target = aquire_fb_target(me)
    return [text: "もっとFacebook使ってリア充になって欲しいお"] if fb_target.blank?

    # productionのMySQLだと想定の順序になってくれないのでひとまずidでorder
    tracks = self.tracks.order(:id)
    raise "Could not find any tracks for channel_id = #{channel_id}, topic_id = #{topic.id}" if tracks.blank?

    inherited_value = nil

    tracks.map do |track|
      json_elem, inherited_value = track.to_json_element(fb_target, inherited_value)
      json_elem
    end
  end

  private
  def aquire_fb_target(me)
    me.send(self.target.to_sym)
      .reject { |fb_target| %w(home feed).include?(self.target) && fb_target.message.blank? }
      .sample
  end
end
