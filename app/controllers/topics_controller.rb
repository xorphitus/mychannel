# -*- coding: utf-8 -*-
class TopicsController < ApplicationController
  include Authentication

  def emit
    me = FbGraph::User.me(@access_token).fetch

    ret = []

    r = rand 2

    if r == 1 then
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
        ret.push({'text' => rss.entries.first.title})
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
