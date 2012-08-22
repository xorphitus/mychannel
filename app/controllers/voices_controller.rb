# -*- coding: utf-8 -*-

class VoicesController < ApplicationController
  include Authentication

  def emit
    text = params[:text].gsub(/\s+/, ",").gsub(/[a-zA-Z]+/) { |m| m.to_katakana }

    if text.length > 100
      # TODO できるだけ最後の句読点で切る
      text = text[0, 97] + "以下略"
    end

    voice = Net::HTTP.get "translate.google.co.jp", "/translate_tts?tl=ja&ie=utf-8&q=#{URI.encode text}"
    send_data voice, type: "audio/mpeg"
  end

end
