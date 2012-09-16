# -*- coding: utf-8 -*-
module TopicsHelper
  def get_topic_target topic
    items = []
    items.push({value: "feed", label: "自分の投稿"})
    items.push({value: "home", label: "友達の投稿"})
    items.push({value: "music", label: "好きな音楽"})
    items.push({value: "free", label: "自由な文章"})

    unless topic.id.nil?
      return [items.find { |item| item[:value] == topic.target }]
    end
    items
  end

  def get_trac_target topic
    items = []
    case topic.target
    when "home", "feed"
      items.push(["投稿内容", "message"])
      items.push(["投稿した人", "user"])
      items.push(["いいねした人数", "likes"])
      items.push(["コメント", "comment"])
      items.push(["コメントした人", "comment_user"])
    when "music"
      items.push(["好きな音楽の情報", "prev"])
    when "free"
      items.push(["入力した文章", "prev"])
    end
    items.push(["直前に使った言葉", "prev"])
  end
end
