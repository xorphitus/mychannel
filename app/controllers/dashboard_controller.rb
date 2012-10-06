# -*- coding: utf-8 -*-
class DashboardController < ApplicationController
  include Authentication

  def index
    @me = fb_me
    channels = Channel.find(:all, conditions: {publish_flag: true})
    @channel_list = channels.map { |channel| [channel.name, channel.id] }
  end
end
