# -*- coding: utf-8 -*-

# The class returns voice: binary audio stream
class Voice
  def self.content_type
    "audio/mpeg"
  end

  # max_lenを越える文字列の場合, suffixを含めて文字数がmax_lenとなるように切り詰める
  def self.limit(str, max_len, suffix)
    if str.size > max_len
      if suffix.blank?
        return str[0, max_len]
      else
        return str[0, max_len - suffix.size + 1] + suffix
      end
    end
    str
  end

  def self.adjust_text(str)
    limit(str.gsub(/\s+/, ",").roman_to_katakana, 100, "以下略")
  end

  def self.get(text)
    target_text = URI.encode(adjust_text(text))
    Net::HTTP.get "translate.google.co.jp", "/translate_tts?tl=ja&ie=utf-8&q=#{target_text}"
  end
end
