# -*- coding: utf-8 -*-
class ChannelsController < ApplicationController
  before_filter :require_authentication

  def index
    @channels = Channel.where(publish_flag: true)

    respond_to do |format|
      format.html
    end
  end

  # 番組として再生する内容 (story) をJSONデータとして返却する
  # クライアント (View層のラジオプレイヤー) はこのJSONデータに基づいて番組の再生をする
  def show
    @channel = Channel.find(params[:id])

    respond_to do |format|
      format.json { render json: @channel.to_story(fb_me) }
    end
  end
end
