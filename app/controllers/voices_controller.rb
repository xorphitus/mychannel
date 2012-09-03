# -*- coding: utf-8 -*-
require 'net/http'

class VoicesController < ApplicationController
  include Authentication

  def emit
    text = params[:text].gsub(/\s+/, ',').gsub(/[a-zA-Z]+/) {|m| m.to_katakana}
    if text.length > 100 then
      # TODO できるだけ最後の句読点で切る
      text = text[0, 97] + '以下略'
    end

    voice = get_voice(text)
    if voice.length == 0 then
      logger.debug 'failed to get voice data!'
      logger.debug text
      voice = get_voice('音声に変換できない文章が設定されました。ごめんなさい')
    end
    send_data voice, :type => 'audio/mpeg'
  end

  def get_voice(text)
    Net::HTTP.get 'translate.google.co.jp', "/translate_tts?tl=ja&ie=utf-8&q=#{text}"
  end
end
