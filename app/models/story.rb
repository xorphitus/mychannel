# -*- coding: utf-8 -*-
require "nokogiri"
require "open-uri"
require "cgi"

# Arrayにrandメソッドを追加
class Array
  # get randan element of array
  def rand
    if self.empty?
      return nil
    end
    return self[Kernel::rand self.length]
  end
end

# View層のラジオプレイヤーに読ませるJSONデータを生成する
class Story
  def self.get(me, channel_id)
    # TODO inner join!
    channel = Channel.find_by_id(channel_id)
    if channel.nil?
      # TODO
    else
      topics = channel.topics
      if topics.empty?
        # TODO
      end
    end

    topic = topics.rand
    tracs = topic.tracs

    fb_targets = me.send(topic.target.to_sym)
    if topic.target == "home" || topic.target == "feed"
      # TODO 自分のポストは除去する
      fb_targets.select! { |item| !item.message.nil? }
    end
    if fb_targets.nil?
      return [({text: "もっとFacebook使ってリア充になって欲しいお"})]
    end

    result_json_array = []
    fb_target = fb_targets.rand

    inherited_value = nil
    trac_reader = TracReader.new

    tracs.each do |trac|
      trac_target = trac.target
      if trac_target == "prev"
        value = inherited_value
      else
        value = fb_target
        trac_target.split(".").each do |i|
          value = value.send(i.to_sym)
        end
        inherited_value = value
      end

      structured_trac = trac_reader.send(trac.action.to_sym, value)
      json_elem = structured_trac.to_hash
      if structured_trac.text_decoration_flag
        if structured_trac.inheritance_flag
          inherited_value = structured_trac.text
        end
        json_elem[:text] = "#{trac.pre_content}#{inherited_value}#{trac.post_content}"
      end
      result_json_array.push(json_elem)
    end

    return result_json_array
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
    result.text = YaCan::Keyphrase.extract(val).phrases.rand

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
      relational_words = targets.rand.split(" ").reject { |item| [val.downcase, "#{val.downcase}とは"].include?(item.downcase) }
      if relational_words.empty?
        result.text = "とくに連想するものはありませんが"
        result.inheritance_flag = false
        result.text_decoration_flag = false
      else
        result.text = relational_words.rand
      end
    end

    return result
  end

  def news val
    result = StructuredTrac.new
    rss = SimpleRSS.parse(open("https://news.google.com/news/feeds?ned=us&ie=UTF-8&oe=UTF-8&q=#{URI.encode(val)}&lr&output=atom&num=5&hl=ja"))
    news = rss.entries.rand
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
    video_obj = YoutubeSearch.search(val).rand
    result.video = [{url: "http://youtube.com/v/" + video_obj["video_id"], name: video_obj["name"]}]

    return result
  end
end
