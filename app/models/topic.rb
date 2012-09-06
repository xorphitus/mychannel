# -*- coding: utf-8 -*-
require 'xmlrpc/client'

# Arrayにrandメソッドを追加
# TODO 外出しすべき？
class Array
  # get randan element of array
  def rand
    if self.empty? then
      return nil
    end
    self[Kernel::rand self.length]
  end
end

# このモジュールのメソッドがランダムで呼ばれる
# トピックを増やしたければ任意の箇所でこのモジュールにメソッドを追加すればよい
module TopicGenerator
  # ウォールの内容 (ランダム) とそこに含まれるキーワードに関連したニュースを取得
  def get_wall_and_news me
    targets = me.home.select {|item| !item.message.nil?}
    if targets.empty? then
      return [({'text' => '最近はお友達のコメントもご無沙汰ですね'})]
    end

    ret = []
    post = targets.rand
    text = post.from().name + "さんからのポストです。\n" + post.message

    ret.push({'text' => text})

    YaCan.appid = Settings.yahoo.app_id
    k = YaCan::Keyphrase.extract post.message
    unless k.phrases.empty? then
      keyphrase = k.phrases[0]
      ret.push({'text' => keyphrase + 'といえば'})
      rss = SimpleRSS.parse open("https://news.google.com/news/feeds?ned=us&ie=UTF-8&oe=UTF-8&q=#{URI.encode keyphrase}&lr&output=atom&num=5&hl=ja")
      if rss.entries.first.nil? then
        ret.push({'text' => '関連ニュースはないみたいです'})
      else
        ret.push({'text' => rss.entries.first.title})
        ret.push({'text' => 'なんてニュースがあるみたいです'})
      end
    end

    return ret
  end

  # 自分の投稿 (ランダム) とそこに含まれるキーワードから想起されるワードを取得
  def get_mypost_and_relatedword me
    targets = me.feed.select {|item| !item.message.nil?}
    if targets.empty? then
      return [({'text' => '最近はFacebookへの投稿をしていないようですね'})]
    end

    ret = []
    post = targets.rand
    ret.push({'text' => '先日のあなたの投稿です'})
    message = post.message
    ret.push({'text' => message})

    # TODO ここは友達のリプライを取得して感情APIを叩くようにする
    YaCan.appid = Settings.yahoo.app_id
    k = YaCan::Keyphrase.extract post.message
    unless k.phrases.empty? then
      keyphrase = k.phrases[0]
      ret.push({'text' => keyphrase + 'といえば'})
      server = XMLRPC::Client.new("d.hatena.ne.jp", "/xmlrpc")
      result = server.call("hatena.getSimilarWord", {
                             "wordlist" => [keyphrase]
                           })
      words = result['wordlist'].map {|v| v['word'] }
      unless words.empty? then
        ret.push({'text' => words.rand + 'を思い浮かべますね'})
      else
        ret.push({'text' => '特に何も思い浮かびませんね'})
      end
    end

    return ret
  end

  # お気に入りと思しき音楽を取得
  def get_favorite_music me
    ret = []

    music_list = me.music
    if music_list.empty? then
      text = '音楽はあまりお好みではないですか?'
      return ret.push({'text' => text})
    end

    text = 'では、あなたのお気に入り、かもしれない一曲をどうぞ'
    ret.push({'text' => text})

    keyword = music_list.rand.name
    video_obj = YoutubeSearch.search(keyword).rand
    video = {'video' => [{'url' => 'http://youtube.com/v/' + video_obj['video_id'], 'name' => video_obj['name']}]}
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
class Topic
  extend TopicGenerator
end
def Topic.get me
  self.send(TopicGenerator.public_instance_methods.rand, me)
end
