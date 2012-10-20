# -*- coding: utf-8 -*-
class Track < ActiveRecord::Base
  belongs_to :topic
  attr_accessible :action, :order, :post_content, :pre_content, :target

  validates :topic_id, presence: true
  validates :action, presence: true
  validates :target, presence: true
  validates :pre_content, length: {maximum: 100}
  validates :post_content, length: {maximum: 100}

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
    def self.plane(val)
      text = val
      urls = URI.extract(val).select { |uri| uri.match(/^(https?|ftp)/) }
      unless urls.empty?
        urls.each do |url|
          text = text.gsub!(url, "")
        end
      end

      StructuredTrack.new(text, urls)
    end

    def self.keyword(val)
      YaCan.appid = Settings.yahoo.app_id
      text = YaCan::Keyphrase.extract(val).phrases.sample
      StructuredTrack.new(text)
    end

    def self.relation(val)
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

    def self.news(val)
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

    def self.youtube(val)
      video_obj = YoutubeSearch.search(val).sample
      video = [{url: "http://youtube.com/v/#{video_obj['video_id']}", name: video_obj["name"]}]
      StructuredTrack.new(nil, nil, video)
    end
  end

  def to_json_element(fb_attribute, inherited_value)
    structured_track = TrackReader.send(self.action.to_sym, fb_attribute)
    json_elem = structured_track.to_hash
    if structured_track.decorate_text?
      inherited_value = structured_track.text if structured_track.inherited?
      json_elem[:text] = "#{self.pre_content}#{inherited_value}#{self.post_content}"
    end
    [json_elem, inherited_value]
  end
end
