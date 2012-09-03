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

    # TODO get news
    # http://billboardtop100.net/2011/09/google-news-rss-feed-api.html
    # http://simple-rss.rubyforge.org/

    render :json => ret
  end
end
