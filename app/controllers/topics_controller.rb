# -*- coding: utf-8 -*-
require 'xmlrpc/client'

class TopicsController < ApplicationController
  include Authentication

  def emit
    me = FbGraph::User.me(@access_token).fetch

    ret = []

    # TODO refactor! refactor! refactor!
    r = rand 3

    if r == 0 then
      # get latest post on the wall
      targets = me.home.select {|item| !item.message.nil?}
      post = targets[rand targets.length]
      text = post.from().name + "さんからのポストです。\n" + post.message

      ret.push({'text' => text})

      YaCan.appid = Settings.yahoo.app_id
      k = YaCan::Keyphrase.extract post.message
      if k.phrases.length > 0 then
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
    elsif r == 1 then
      targets = me.feed.select {|item| !item.message.nil?}
      if targets.nil? or  targets.length == 0 then
        ret.push({'text' => '最近はFacebookへの投稿をしていないようですね'})
      else
        post = targets[rand targets.length]
        ret.push({'text' => '先日のあなたの投稿です'})
        message = post.message
        ret.push({'text' => message})

        YaCan.appid = Settings.yahoo.app_id
        k = YaCan::Keyphrase.extract message
        if k.phrases.length > 0 then
          keyphrase = k.phrases[0]
          ret.push({'text' => keyphrase + 'といえば'})
          server = XMLRPC::Client.new("d.hatena.ne.jp", "/xmlrpc")
          result = server.call("hatena.getSimilarWord", {
                                 "wordlist" => [keyphrase]
                               })
          words = result['wordlist'].map {|v| v['word'] }
          if words.length > 0 then
            ret.push({'text' => words[rand words.length] + 'を思い浮かべますね'})
          else
            ret.push({'text' => '特に何も思い浮かびませんね'})
          end
        end
      end
    else
      # get favorite music
      music_list = me.music
      if music_list.length == 0 then
        text = '音楽はあまりお好みではないですか?'
        return ret.push({'text' => text})
      end

      text = 'では、あなたのお気に入り、かもしれない一曲をどうぞ'
      ret.push({'text' => text})

      keyword = music_list[rand music_list.length].name
      video_obj = YoutubeSearch.search(keyword).first
      video = {'video' => [{'url' => 'http://youtube.com/v/' + video_obj['video_id'], 'name' => video_obj['name']}]}
      ret.push(video)
    end

    render :json => ret
  end
end
