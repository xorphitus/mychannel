# -*- coding: utf-8 -*-
require "nokogiri"
require "open-uri"
require "cgi"

# View層のラジオプレイヤーに読ませるJSONデータを生成する
class Story
  def self.get(me, channel_id)
    topics = Topic.where(channel_id: channel_id)
    if topics.empty?
      raise "Could not find any topics for channel_id = #{channel_id}"
    end

    topic = topics.sample
    tracs = topic.tracs
    if tracs.empty?
      raise "Could not find any tras for channel_id = #{channel_id}, topic_id = #{topic.id}"
    end

    fb_targets = me.send(topic.target.to_sym)
    if ["home", "feed"].include?(topic.target)
      fb_targets.reject! { |i| i.message.nil? }
    end
    if fb_targets.nil?
      return [({text: "もっとFacebook使ってリア充になって欲しいお"})]
    end

    content_array = []

    inherited_value = nil
    trac_reader = TracReader.new

    tracs.each do |trac|
      if trac.target == "prev"
        fb_target = inherited_value
      else
        fb_target = fb_targets.sample
        trac.target.split(".").each { |i| fb_target = fb_target.send(i.to_sym) }
        inherited_value = fb_target
      end

      structured_trac = trac_reader.send(trac.action.to_sym, fb_target)
      json_elem = structured_trac.to_hash
      if structured_trac.text_decoration_flag
        if structured_trac.inheritance_flag
          inherited_value = structured_trac.text
        end
        json_elem[:text] = "#{trac.pre_content}#{inherited_value}#{trac.post_content}"
      end
      content_array.push(json_elem)
    end

    return {metadata: {hash: content_array.hash}, content: content_array}
  end
end

# TracをブラウザのハンドリングできるJSON形式に変換する前段階の構造
class StructuredTrac
  attr_accessor :text, :link, :video, :text_decoration_flag, :inheritance_flag

  def initialize
    self.text_decoration_flag = true
    self.inheritance_flag = true
  end

  def to_hash
    hash = {}
    [:text, :link, :video].each do |attr|
      value = self.send(attr)
      if value
        hash[attr] = value
      end
    end
    return hash
  end
end

# model - Trac の内容から返却するJSONの要素を生成する
class TracReader
  def plane val
    result = StructuredTrac.new
    result.text = val
    uris = URI.extract(val)
    unless uris.empty?
      result.link = uris
      uris.each do |uri|
        result.text.gsub!(uri, "")
      end
    end

    return result
  end

  def keyword val
    result = StructuredTrac.new
    YaCan.appid = Settings.yahoo.app_id
    result.text = YaCan::Keyphrase.extract(val).phrases.sample

    return result
  end

  def relation val
    result = StructuredTrac.new

    relations = Nokogiri::XML(open("http://search.yahooapis.jp/AssistSearchService/V1/webunitSearch?appid=#{Settings.yahoo.app_id}&query=#{URI.encode(val)}"))

    targets = relations.css("Result").map { |node| node.content }

    if targets.empty?
      result.text = "とくに連想するものはありませんが"
      result.inheritance_flag = false
      result.text_decoration_flag = false
    else
      relational_words = targets.sample.split(" ").reject { |item| [val.downcase, "#{val.downcase}とは"].include?(item.downcase) }
      if relational_words.empty?
        result.text = "とくに連想するものはありませんが"
        result.inheritance_flag = false
        result.text_decoration_flag = false
      else
        result.text = relational_words.sample
      end
    end

    return result
  end

  def news val
    result = StructuredTrac.new
    rss = SimpleRSS.parse(open("https://news.google.com/news/feeds?ned=us&ie=UTF-8&oe=UTF-8&q=#{URI.encode(val)}&lr&output=atom&num=5&hl=ja"))
    news = rss.entries.sample
    if news.nil?
      result.text = "関連ニュースはないみたいです"
      result.text_decoration_flag = false
      return result
    end
    result.text = news.title

    link = CGI::unescapeHTML(news.link)
    delimiter = "&url="
    link = link[link.index(delimiter) + delimiter.size, link.size]
    link = URI.decode(link)
    result.link = [link]

    return result
  end

  def youtube val
    result = StructuredTrac.new
    video_obj = YoutubeSearch.search(val).sample
    result.video = [{url: "http://youtube.com/v/" + video_obj["video_id"], name: video_obj["name"]}]

    return result
  end
end
