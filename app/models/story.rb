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

# TODO この辺の実装がモヤっとしてる. もっとカッコいいのがありそう
#
# とりあえず下記フォーマットのJSON (に変換可能な) オブジェクトを返す仕様
# {
#   text: '読み上げます',
#   link: [{url: 'http://hoge.com', title: 'タイトル'}],
#   image: [{url: 'http://hoge.com', title: 'タイトル'}],
#   video: [{url: 'http://hoge.com', title: 'タイトル'}]
# }
#
class Story
  extend StoryGenerator
end

def Story.get me
  # TODO fix the line below
  #channels = Channel.find :all, include: :user, conditions: ["user.fb_id = ?", me.user_id]
  channels = Channel.find(:all)
  if channels.nil? then
    return self.send(StoryGenerator.public_instance_methods.rand, me)
  end
  # TODO USER INNER JOIN
  #topics = Topic.find_by_channel_id :all, channels.first.id
  #tracs = Trac.find_by_topic_id :all, topics.rand.id
  tracs = Trac.find :all
  if tracs.empty? then
    return self.send(StoryGenerator.public_instance_methods.rand, me)
  end

  targets = me.home.select {|item| !item.message.nil?}
  if targets.empty? then
    return [({'text' => '最近はお友達のコメントもご無沙汰ですね'})]
  end

  ret = []
  post = targets.rand

  val = nil
  tracs.each do |trac|
    trac_target = trac.target
    unless trac_target == "prev" then
      val = post.send trac_target.to_sym
    end
    case trac.action
    when "keyword" then
      YaCan.appid = Settings.yahoo.app_id
      val = YaCan::Keyphrase.extract(val).phrases.rand
    when "relation" then
      server = XMLRPC::Client.new("d.hatena.ne.jp", "/xmlrpc")
      result = server.call("hatena.getSimilarWord", {
                             "wordlist" => [keyphrase]
                           })
      words = result['wordlist'].map {|v| v['word'] }
      if words.empty? then
        ret.push({'text' => '特に何も思い浮かびませんね'})
        break
      end
      val = words.rand
    when "news" then
      rss = SimpleRSS.parse open("https://news.google.com/news/feeds?ned=us&ie=UTF-8&oe=UTF-8&q=#{URI.encode val}&lr&output=atom&num=5&hl=ja")
      if rss.entries.first.nil? then
        ret.push({'text' => '関連ニュースはないみたいです'})
        break
      end
      val = rss.entries.first.title
    when "youtube" then
      video_obj = YoutubeSearch.search(val).rand
      video = {'video' => [{'url' => 'http://youtube.com/v/' + video_obj['video_id'], 'name' => video_obj['name']}]}
      break ret.push video
    end
    ret.push({'text' => trac.pre_content + val + trac.post_content})
  end
  return ret
end
