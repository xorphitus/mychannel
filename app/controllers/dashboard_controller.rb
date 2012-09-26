# -*- coding: utf-8 -*-
class DashboardController < ApplicationController
  include Authentication

  def index
    @me = get_fb_me
    channels = Channel.find(:all, conditions: {publish_flag: true})
    @channel_list = [["サンプル", 0]]
    channels.each do |channel|
      @channel_list.push([channel.name, channel.id])
    end
  end
end
