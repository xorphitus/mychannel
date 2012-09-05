# -*- coding: utf-8 -*-

class VoicesController < ApplicationController
  include Authentication

  def emit
    text = params[:text].gsub(/\s+/, ',').gsub(/[a-zA-Z]+/) {|m| m.to_katakana}

    if text.length > 100 then
      # TODO できるだけ最後の句読点で切る
      text = text[0, 97] + '以下略'
    end

    voice = get_voice text
    send_data voice, :type => 'audio/mpeg'
  end

  # TODO アクセシビリティを下げる？
  def get_voice text
    begin
      encoded = URI.encode text
      uri = URI.parse "http://translate.google.co.jp/translate_tts?tl=ja&ie=utf-8&q=#{encoded}"
    rescue URI::InvalidURIError
      return get_voice_on_fail text
    end

    voice = Net::HTTP.get uri
    if voice.length == 0 then
      voice = get_voice_on_fail text
    end

    return voice
  end

  # TODO アクセシビリティを下げる？
  def get_voice_on_fail text
    if text.nil? then
      # TODO herokuでは logger.debug 使用不可
      logger.debug 'failed to get voice data!'
      logger.debug text
    end
    get_voice '音声に変換できない文章が設定されました。ごめんなさい'
  end
end
