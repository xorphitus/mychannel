# -*- coding: utf-8 -*-

class VoicesController < ApplicationController
  before_filter :require_authentication

  # 受け取ったテキストから音声データを返却する
  def show
    send_data(Voice.get(params[:id]), type: Voice.content_type)
  end
end
