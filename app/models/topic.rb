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

  # TrackをブラウザのハンドリングできるJSON形式に変換する前段階の構造
  class StructuredTrack
    attr_reader :text, :links, :video
    attr_writer :text_decoration, :inheritance

    def initialize(text = nil, links = nil, video = nil)
      @text = text
      @links = links
      @video = video
      @text_decoration = true
      @inheritance = true
    end

    def decorate_text?
      @text_decoration
    end

    def inherited?
      @inheritance
    end

    def to_hash
      hash = {}
      [:text, :links, :video].each do |attr|
        value = self.send(attr)
        if value
          hash[attr] = value
        end
      end
      hash
    end
  end

  # model - Track の内容から返却するJSONの要素を生成する
  class TrackReader
    def plane(val)
      text = val
      urls = URI.extract(val).select { |uri| uri.match(/^(https?|ftp)/) }
      unless urls.empty?
        urls.each do |url|
          text = text.gsub!(url, "")
        end
      end

      StructuredTrack.new(text, urls)
    end

    def keyword(val)
      YaCan.appid = Settings.yahoo.app_id
      text = YaCan::Keyphrase.extract(val).phrases.sample
      StructuredTrack.new(text)
    end

    def relation(val)
      relations = Nokogiri::XML(open("http://search.yahooapis.jp/AssistSearchService/V1/webunitSearch?appid=#{Settings.yahoo.app_id}&query=#{URI.encode(val)}"))

      targets = relations.css("Result").map { |node| node.content }

      def empty
        empty = StructuredTrack.new("とくに連想するものはありませんが")
        empty.inheritance = false
        empty.text_decoration = false
        empty
      end

      return empty if targets.empty?

      relational_words = targets.sample.split(" ").reject { |item| [val.downcase, "#{val.downcase}とは"].include?(item.downcase) }

      relational_words.empty? ? empty : StructuredTrack.new(relational_words.sample)
    end

    def news(val)
      rss = SimpleRSS.parse(open("https://news.google.com/news/feeds?ned=us&ie=UTF-8&oe=UTF-8&q=#{URI.encode(val)}&lr&output=atom&num=5&hl=ja"))
      news = rss.entries.sample
      if news.nil?
        empty = StructuredTrack.new("関連ニュースはないみたいです")
        empty.text_decoration = false
        return empty
      end

      text = news.title
      link = CGI::unescapeHTML(news.link)
      delimiter = "&url="
      start_index = link.index(delimiter) + delimiter.size
      link = link[start_index, link.size]
      link = URI.decode(link)

      StructuredTrack.new(text, [link])
    end

    def youtube(val)
      video_obj = YoutubeSearch.search(val).sample
      video = [{url: "http://youtube.com/v/#{video_obj['video_id']}", name: video_obj["name"]}]
      StructuredTrack.new(nil, nil, video)
    end
  end

  def self.select_topic_tree(channel_id)
    topics = Topic.where(channel_id: channel_id)
    raise "Could not find any topics for channel_id = #{channel_id}" if topics.empty?

    topic = topics.sample
    # productionのMySQLだと想定の順序になってくれないのでひとまずidでorder
    tracks = topic.tracks.order(:id)
    raise "Could not find any tras for channel_id = #{channel_id}, topic_id = #{topic.id}" if tracks.empty?

    [topic, tracks]
  end

  def self.aquire_fb_target(me, topic)
    fb_targets = me.send(topic.target.to_sym)
    fb_targets.reject! { |fb_target| fb_target.message.nil? } if %w(home feed).include?(topic.target)
    fb_targets.sample
  end

  def self.to_story_contents(fb_target, tracks)
    inherited_value = nil
    track_reader = TrackReader.new

    tracks.map do |track|
      if track.target == "prev"
        seed = inherited_value
      else
        seed = fb_target
        track.target.split(".").each { |token| seed = seed.send(token.to_sym) }
        inherited_value = seed
      end

      structured_track = track_reader.send(track.action.to_sym, seed)
      json_elem = structured_track.to_hash
      if structured_track.decorate_text?
        inherited_value = structured_track.text if structured_track.inherited?
        json_elem[:text] = "#{track.pre_content}#{inherited_value}#{track.post_content}"
      end
      json_elem
    end
  end

  private_class_method :select_topic_tree, :aquire_fb_target, :to_story_contents


  def self.to_story(me, channel_id)
    topic, tracks = select_topic_tree(channel_id)

    fb_target = aquire_fb_target(me, topic)
    return [({text: "もっとFacebook使ってリア充になって欲しいお"})] if fb_target.nil?

    contents = to_story_contents(fb_target, tracks)
    {metadata: {hash: contents.hash}, contents: contents}
  end
end
