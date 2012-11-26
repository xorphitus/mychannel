# -*- coding: utf-8 -*-

class VoicesController < ApplicationController
  before_filter :require_authentication

  # 受け取ったテキストから音声データを返却する
  def show
    @voice = Voice.get(params[:id])

    respond_to do |format|
      format.mp3 { send_data(@voice, type: Voice.content_type) }
    end
  end
end
