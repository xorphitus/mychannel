# -*- coding: utf-8 -*-

class String
  def limit(max_len, suffix)
    if self.size > max_len
      if suffix.nil?
        return self[0, max_len]
      else
        return self[0, max_len - suffix.size + 1] + suffix
      end
    end

    return self
  end
end

class VoicesController < ApplicationController
  include Authentication

  def emit
    text = params[:text].gsub(/\s+/, ",").roman_to_katakana
    text = text.limit(100, "以下略")

    send_data(Voice.get(text), type: Voice.content_type)
  end
end
