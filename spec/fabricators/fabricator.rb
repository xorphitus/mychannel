# -*- coding: utf-8 -*-
Fabricator(:user) do
  name "user name"
  fb_id Fabricate.sequence.to_s
end

Fabricator(:channel) do
  name "channel name"
  publish_flag true
  user
end

Fabricator(:topic) do
  name "topic name"
  target "feed"
  order 1
  channel
end

Fabricator(:trac01, class_name: :trac) do
  target "message"
  action "plane"
  pre_content "あなたの投稿 "
  post_content ""
  topic
end

Fabricator(:trac02, class_name: :trac) do
  target "prev"
  action "keyword"
  pre_content "「"
  post_content "」といえば"
  topic
end

Fabricator(:trac03, class_name: :trac) do
  target "prev"
  action "relation"
  pre_content "「"
  post_content "」ですが"
  topic
end

Fabricator(:trac04, class_name: :trac) do
  target "prev"
  action "news"
  pre_content ""
  post_content " というニュースがあります"
  topic
end
