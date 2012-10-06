# The class returns voice: binary audio stream
class Voice
  def self.content_type
    "audio/mpeg"
  end

  def self.get(text)
    Net::HTTP.get "translate.google.co.jp", "/translate_tts?tl=ja&ie=utf-8&q=#{URI.encode(text)}"
  end
end
