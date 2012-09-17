# -*- coding: utf-8 -*-
class DashboardController < ApplicationController
  include Authentication

  def index
    @me = get_fb_me
    # TODO inner join!
    user = User.find_by_fb_id(@me.user_id)
    @channel_list = [["サンプル", 0]]
    unless user.nil?
      user.channels.each do |channel|
        @channel_list.push([channel.name, channel.id])
      end
    end
  end
end
