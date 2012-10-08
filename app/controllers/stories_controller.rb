# -*- coding: utf-8 -*-
class StoriesController < ApplicationController
  include Authentication

  # 番組として再生する内容 (story) をJSONデータとして返却する
  # クライアント (View層のラジオプレイヤー) はこのJSONデータに基づいて番組の再生をする
  def emit
    render json: Topic.to_story(fb_me, params[:channel_id])
  end
end
