# -*- coding: utf-8 -*-
class ChannelsController < ApplicationController
  before_filter :require_authentication

  def index
    @me = fb_me
    channels = Channel.find(:all, conditions: {publish_flag: true})
    @channel_list = channels.map { |channel| [channel.name, channel.id] }
  end

  # 番組として再生する内容 (story) をJSONデータとして返却する
  # クライアント (View層のラジオプレイヤー) はこのJSONデータに基づいて番組の再生をする
  def show
    channel_id = params[:id]
    render json: Topic.to_story(fb_me, channel_id)
  end
end
