# -*- coding: utf-8 -*-
class DashboardController < ApplicationController
  before_filter :require_authentication

  def index
    @me = fb_me
    channels = Channel.find(:all, conditions: {publish_flag: true})
    @channel_list = channels.map { |channel| [channel.name, channel.id] }
  end
end
