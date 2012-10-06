# -*- coding: utf-8 -*-

class String
  # max_lenを越える文字列の場合, suffixを含めて文字数がmax_lenとなるように切り詰める
  def limit(max_len, suffix)
    if self.size > max_len
      if suffix.nil?
        return self[0, max_len]
      else
        return self[0, max_len - suffix.size + 1] + suffix
      end
    end

    self
  end
end

class VoicesController < ApplicationController
  include Authentication

  # 受け取ったテキストから音声データを返却する
  def emit
    text = params[:text].gsub(/\s+/, ",").roman_to_katakana
    text = text.limit(100, "以下略")

    send_data(Voice.get(text), type: Voice.content_type)
  end
end
