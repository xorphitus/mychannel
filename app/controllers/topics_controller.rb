# -*- coding: utf-8 -*-
class TopicsController < ApplicationController
  include Authentication

  def emit
    me = FbGraph::User.me(@access_token).fetch

    ret = []

    r = rand 2

    if r == 1 then
      # get latest post on the wall
      target = me.home.find do |item|
        !item.raw_attributes['message'].nil?
      end
      post = target.raw_attributes
      text = post['from']['name'] + "さんからのポストです。\n" + post['message']

      ret.push({'text' => text})
    else
      # get favorite music
      text = 'では、あなたのお気に入り、かもしれない一曲をどうぞ'
      ret.push({'text' => text})

      # TODO https://github.com/grosser/youtube_search
      ret.push({'movie' => text})
    end

    # TODO get news
    # http://billboardtop100.net/2011/09/google-news-rss-feed-api.html
    # http://simple-rss.rubyforge.org/

    render :json => ret
  end
end
