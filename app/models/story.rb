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

# このモジュールのメソッドがランダムで呼ばれる
# トピックを増やしたければ任意の箇所でこのモジュールにメソッドを追加すればよい
# DEPRECATED: DB対応したことによって意味を失った
module StoryGenerator
  # ウォールの内容 (ランダム) とそこに含まれるキーワードに関連したニュースを取得
  def get_wall_and_news me
    targets = me.home.select { |item| !item.message.nil? }
    if targets.empty?
      return [({"text" => "最近はお友達のコメントもご無沙汰ですね"})]
    end

    ret = []
    post = targets.rand
    text = post.from().name + "さんからのポストです。\n" + post.message

    ret.push({'text' => text})

    YaCan.appid = Settings.yahoo.app_id
    k = YaCan::Keyphrase.extract post.message
    unless k.phrases.empty?
      keyphrase = k.phrases[0]
      ret.push({"text" => keyphrase + "といえば"})
      rss = SimpleRSS.parse open("https://news.google.com/news/feeds?ned=us&ie=UTF-8&oe=UTF-8&q=#{URI.encode keyphrase}&lr&output=atom&num=5&hl=ja")
      if rss.entries.first.nil?
        ret.push({"text" => "関連ニュースはないみたいです"})
      else
        ret.push({"text" => rss.entries.first.title})
        ret.push({"text" => "なんてニュースがあるみたいです"})
      end
    end

    return ret
  end

  # 自分の投稿 (ランダム) とそこへのリアクション
  def get_selfpost_and_reactions me
    targets = me.feed.select { |item| !item.message.nil? }
    if targets.empty?
      return [({"text" => "最近はFacebookへの投稿をしていないようですね"})]
    end

    ret = []
    post = targets.rand
    ret.push({"text" => "先日のあなたの投稿です"})
    message = post.message
    ret.push({"text" => message})

    unless post.comments.empty?
      # TODO nameではなくidでrejectしたいけどidが取得できない?!
      comment_data = post.comments.reject { |item| item.from.name == me.name }
      unless comment_data.empty?
        comment = comment_data.rand
        ret.push({"text" => comment.from.name + "さんからのコメントです"})
        ret.push({"text" => comment.message})
      end
    end

    unless post.likes.empty?
      # TODO nameではなくidでrejectしたいけどidが取得できない?!
      like_data = post.likes.reject { |item| item.name == me.name }
      if like_data.length == 1
        ret.push({"text" => like_data.first.name + "さんがイイネと言っています"})
      elsif like_data.length > 1
        ret.push({"text" => "#{like_data.rand.name}さん、ほか#{like_data.length - 1}人が「いいね」と言っています"})
      end
    end

    # TODO ここは友達のリプライを取得して感情APIを叩くようにする
    YaCan.appid = Settings.yahoo.app_id
    k = YaCan::Keyphrase.extract post.message
    unless k.phrases.empty?
      keyphrase = k.phrases[0]
      ret.push({"text" => keyphrase + "といえば"})
      server = XMLRPC::Client.new("d.hatena.ne.jp", "/xmlrpc")
      result = server.call("hatena.getSimilarWord", {
                             "wordlist" => [keyphrase]
                           })
      words = result["wordlist"].map { |v| v['word'] }
      unless words.empty?
        ret.push({"text" => words.rand + "を思い浮かべますね"})
      else
        ret.push({"text" => "特に何も思い浮かびませんね"})
      end
    end

    return ret
  end

  # お気に入りと思しき音楽を取得
  def get_favorite_music me
    ret = []

    music_list = me.music
    if music_list.empty?
      text = '音楽はあまりお好みではないですか?'
      return ret.push({"text" => text})
    end

    ret.push({"text" => "では、あなたのお気に入り、かもしれない一曲をどうぞ"})

    keyword = music_list.rand.name
    video_obj = YoutubeSearch.search(keyword).rand
    video = {"video" => [{"url" => "http://youtube.com/v/" + video_obj["video_id"], "name" => video_obj["name"]}]}
    ret.push(video)
  end

end

# View層のラジオプレイヤーに読ませるJSONデータを生成する
class Story
  extend StoryGenerator
end

def Story.get_default me
  # TODO ダミーのTopic, Tracのモデルを使うよう変更する
  self.send(StoryGenerator.public_instance_methods.rand, me)
end

def Story.get me
  # TODO fix the line below
  #channels = Channel.find :all, include: :user, conditions: ["user.fb_id = ?", me.user_id]
  channels = Channel.find(:all)
  if channels.nil? then
    return Story.get_default me
  end
  # TODO USER INNER JOIN
  topics = channels.rand.topics
  if topics.nil? then
    return Story.get_default me
  end
  topic = topics.rand
  tracs = topic.tracs
  if tracs.empty? then
    return Story.get_default me
  end

  targets = me.send(topic.target.to_sym).select {|item| !item.message.nil?}
  if targets.nil? then
    return [({text: "もっとFacebook使ってリア充になって欲しいお"})]
  end

  ret = []
  target = targets.rand

  val = nil
  trac_reader = TracReader.new

  tracs.each do |trac|
    trac_target = trac.target
    unless trac_target == "prev" then
      val = target.send(trac_target.to_sym)
    end
    read_trac = trac_reader.send(trac.action.to_sym, val)
    case read_trac.class
    when "String"
      val = read_trac
    when "Hash"
      ret.push(read_trac)
      break
    end
    ret.push({text: trac.pre_content + val + trac.post_content})
  end
  return ret
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
