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

    def initialize(args = {})
      @text = args[:text]
      @links = args[:links]
      @video = args[:video]
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
      Hash[
           [:text, :links, :video].map { |attr| [attr, self.send(attr)] }
             .select { |k, v| v.present? }
          ]
    end

    def self.missing_track(text)
      st_track = StructuredTrack.new(text: text)
      st_track.instance_eval do
        @text_decoration = false
        @inheritance = false
      end
      st_track
    end
  end

  # Trackの内容から返却するJSONの要素を生成する
  class TrackReader
    def self.plane(val)
      text = val
      urls = URI.extract(val).select { |uri| uri.match(/^(https?|ftp)/) }
      unless urls.blank?
        urls.each do |url|
          text = text.gsub!(url, "")
        end
      end

      StructuredTrack.new(text: text, links: urls)
    end

    def self.keyword(val)
      YaCan.appid = Settings.yahoo.app_id
      text = YaCan::Keyphrase.extract(val).phrases.sample
      StructuredTrack.new(text: text)
    end

    def self.relation(val)
      relations = Nokogiri::XML(open("http://search.yahooapis.jp/AssistSearchService/V1/webunitSearch?appid=#{Settings.yahoo.app_id}&query=#{URI.encode(val)}"))
      targets = relations.css("Result").map { |node| node.content }

      return StructuredTrack.missing_track("とくに連想するものはありませんが") if targets.blank?

      # 'hogehogeとは' は関連ワードじゃないので除去
      relational_words = targets.sample.split(" ").reject { |item| [val.downcase, "#{val.downcase}とは"].include?(item.downcase) }
      relational_words.blank? ? StructuredTrack.missing_track("とくに連想するものはありませんが") : StructuredTrack.new(text: relational_words.sample)
    end

    def self.news(val)
      rss = SimpleRSS.parse(open("https://news.google.com/news/feeds?ned=us&ie=UTF-8&oe=UTF-8&q=#{URI.encode(val)}&lr&output=atom&num=5&hl=ja"))
      news = rss.entries.sample

      return StructuredTrack.missing_track("関連ニュースはないみたいです") if news.blank?

      text = news.title
      link = CGI::unescapeHTML(news.link)
      delimiter = "&url="
      start_index = link.index(delimiter) + delimiter.size
      link = link[start_index, link.size]
      link = URI.decode(link)

      StructuredTrack.new(text: text, links: [link])
    end

    def self.youtube(val)
      video_obj = YoutubeSearch.search(val).sample
      video = [{url: "http://youtube.com/v/#{video_obj['video_id']}", name: video_obj["name"]}]
      StructuredTrack.new(video: video)
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
