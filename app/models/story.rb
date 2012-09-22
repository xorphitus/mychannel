# -*- coding: utf-8 -*-
require 'xmlrpc/client'
require "cgi"

# Arrayにrandメソッドを追加
class Array
  # get randan element of array
  def rand
    if self.empty?
      return nil
    end
    self[Kernel::rand self.length]
  end
end

class TracParseException < Exception; end

# View層のラジオプレイヤーに読ませるJSONデータを生成する
class Story; end

# デフォルトの音声コンテンツを返す
# TODO YAMLとかに外出しした方がいいんだろうか
def Story.get_default_topics
  topic1 = Topic.new(target: "feed")
  trac1_1 = Trac.new(target: "message", action: "plane", pre_content: "あなたの投稿 ", post_content: "")
  trac1_2 = Trac.new(target: "prev", action: "keyword", pre_content: "", post_content: "といえば")
  trac1_3 = Trac.new(target: "prev", action: "news", pre_content: "", post_content: " というニュースがあります")
  topic1.tracs = [trac1_1, trac1_2, trac1_3]

  topic2 = Topic.new(target: "home")
  trac2_1 = Trac.new(target: "from.name", action: "plane", pre_content: "", post_content: "さんからの投稿")
  trac2_2 = Trac.new(target: "message", action: "plane", pre_content: "", post_content: "")
  trac2_3 = Trac.new(target: "prev", action: "keyword", pre_content: "", post_content: "といえば")
  trac2_4 = Trac.new(target: "prev", action: "news", pre_content: "", post_content: " というニュースがあります")
  topic2.tracs = [trac2_1, trac2_2, trac2_3, trac2_4]

  topic3 = Topic.new(target: "music")
  trac3_1 = Trac.new(target: "name", action: "plane", pre_content: "あなたのお気に入り ", post_content: "にちなんだ一曲をどうぞ")
  trac3_2 = Trac.new(target: "prev", action: "youtube", pre_content: "", post_content: "")
  topic3.tracs = [trac3_1, trac3_2]

  [topic1, topic2, topic3]
end

# 音声コンテンツのJSONデータ (未シリアライズ) を返す
def Story.get(me, channel_id)
  if channel_id.nil? then
    topics = Story.get_default_topics
  else
    # TODO inner join!
    channel = Channel.find_by_id(channel_id)
    if channel.nil?
      topics = Story.get_default_topics
    else
      topics = channel.topics
      if topics.nil? then
        return [({text: "この番組は作りかけなので、他の番組を選んで下さい"})]
      end
    end
  end

  topic = topics.rand
  tracs = topic.tracs

  fb_targets = me.send(topic.target.to_sym)
  if topic.target == "home" || topic.target == "feed"
    # TODO 自分のポストは除去する
    fb_targets.select! { |item| !item.message.nil? }
  end
  if fb_targets.nil? then
    return [({text: "もっとFacebook使ってリア充になって欲しいお"})]
  end

  result_json_array = []
  fb_target = fb_targets.rand

  inherited_value = nil
  trac_reader = TracReader.new

  tracs.each do |trac|
    trac_target = trac.target
    unless trac_target == "prev" then
      recv = fb_target
      trac_target.split(".").each do |i|
        recv = recv.send(i.to_sym)
      end
      inherited_value = recv
    end
    structured_trac = trac_reader.send(trac.action.to_sym, inherited_value)
    json_elem = structured_trac.to_hash
    if structured_trac.text_decoration_flag
      inherited_value = structured_trac.text
      json_elem[:text] = "#{trac.pre_content}#{inherited_value}#{trac.post_content}"
    end
    result_json_array.push(json_elem)
  end

  result_json_array
end

# TracをブラウザのハンドリングできるJSON形式に変換する前段階の構造
class StructuredTrac
  attr_accessor :text, :link, :video, :text_decoration_flag
  def initialize
    self.text_decoration_flag = true
  end
  def to_hash
    hash = {}
    [:text, :link, :video].each do |attr|
      value = self.send(attr)
      if value
        hash[attr] = value
      end
    end
    hash
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

    result
  end

  def keyword val
    result = StructuredTrac.new
    YaCan.appid = Settings.yahoo.app_id
    result.text = YaCan::Keyphrase.extract(val).phrases.rand

    result
  end

  def relation val
    result = StructuredTrac.new
    server = XMLRPC::Client.new("d.hatena.ne.jp", "/xmlrpc")
    result = server.call("hatena.getSimilarWord", {
                           "wordlist" => [keyphrase]
                         })
    words = result["wordlist"].map { |v| v["word"] }
    if words.empty? then
      result.text = "特に何も思い浮かびません"
      result.text_decoration_flag = false
      return result
    end
    result.text = words.rand

    result
  end

  def news val
    result = StructuredTrac.new
    rss = SimpleRSS.parse(open("https://news.google.com/news/feeds?ned=us&ie=UTF-8&oe=UTF-8&q=#{URI.encode(val)}&lr&output=atom&num=5&hl=ja"))
    news = rss.entries.rand
    if news.nil? then
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

    result
  end

  def youtube val
    result = StructuredTrac.new
    video_obj = YoutubeSearch.search(val).rand
    result.video = [{url: "http://youtube.com/v/" + video_obj["video_id"], name: video_obj["name"]}]

    result
  end
end
