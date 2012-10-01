# The class returns voice: binary audio stream
class Voice
  def self.content_type
    return "audio/mpeg"
  end

  def self.get(text)
    return Net::HTTP.get "translate.google.co.jp", "/translate_tts?tl=ja&ie=utf-8&q=#{URI.encode(text)}"
  end
end
