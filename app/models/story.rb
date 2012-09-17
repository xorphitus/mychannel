# -*- coding: utf-8 -*-
require 'xmlrpc/client'

# Arrayにrandメソッドを追加
# TODO 外出しすべき？
class Array
  # get randan element of array
  def rand
    if self.empty?
      return nil
    end
    self[Kernel::rand self.length]
  end
end

# View層のラジオプレイヤーに読ませるJSONデータを生成する
class Story
end

def Story.get_default me
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

def Story.get(me, channel_id)
  if channel_id.nil? then
    topics = Story.get_default me
  else
    # TODO inner join!
    channel = Channel.find_by_id(channel_id)
    if channel.nil?
      topics = Story.get_default me
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
    fb_targets.select! { |item| !item.message.nil? }
  end
  if fb_targets.nil? then
    return [({text: "もっとFacebook使ってリア充になって欲しいお"})]
  end

  result_json = []
  fb_target = fb_targets.rand

  val = nil
  trac_reader = TracReader.new

  tracs.each do |trac|
    trac_target = trac.target
    unless trac_target == "prev" then
      recv = fb_target
      trac_target.split(".").each do |i|
        recv = recv.send(i.to_sym)
      end
      val = recv
    end
    read_trac = trac_reader.send(trac.action.to_sym, val)

    case read_trac.class.to_s
    when "String"
      val = read_trac
      result_json.push({text: trac.pre_content + val + trac.post_content})
    when "Hash"
      result_json.push(read_trac)
    end
  end
  return result_json
end

# model - Trac の内容から返却するJSONの要素を生成する
class TracReader
  def plane val
    val
  end

  def keyword val
    YaCan.appid = Settings.yahoo.app_id
    YaCan::Keyphrase.extract(val).phrases.rand
  end

  def relation val
    server = XMLRPC::Client.new("d.hatena.ne.jp", "/xmlrpc")
    result = server.call("hatena.getSimilarWord", {
                           "wordlist" => [keyphrase]
                         })
    words = result["wordlist"].map {|v| v["word"] }
    if words.empty? then
      return {text: "特に何も思い浮かびません"}
    end
    words.rand
  end

  def news val
    rss = SimpleRSS.parse open("https://news.google.com/news/feeds?ned=us&ie=UTF-8&oe=UTF-8&q=#{URI.encode val}&lr&output=atom&num=5&hl=ja")
    if rss.entries.first.nil? then
      return {text: "関連ニュースはないみたいです"}
    end
    rss.entries.first.title
  end

  def youtube val
    video_obj = YoutubeSearch.search(val).rand
    {video: [{url: "http://youtube.com/v/" + video_obj['video_id'], name: video_obj["name"]}]}
  end
end
