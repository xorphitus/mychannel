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

# topic00
Fabricator(:topic00, class_name: :topic) do
  name "topic name"
  target "feed"
  order 1
  channel
end

Fabricator(:trac00, class_name: :trac) do
  target "message"
  action "plane"
  pre_content "pre "
  post_content " post"
  topic
end

Fabricator(:trac01, class_name: :trac) do
  target "prev"
  action "keyword"
  pre_content "pre "
  post_content " post"
  topic
end

Fabricator(:trac02, class_name: :trac) do
  target "prev"
  action "relation"
  pre_content "pre "
  post_content " post"
  topic
end

Fabricator(:trac03, class_name: :trac) do
  target "prev"
  action "news"
  pre_content "pre "
  post_content " post"
  topic
end

# topic01
Fabricator(:topic01, class_name: :topic) do
  name "topic name"
  target "home"
  order 1
  channel
end

Fabricator(:trac10, class_name: :trac) do
  target "from.name"
  action "plane"
  pre_content "pre "
  post_content " post"
  topic
end

Fabricator(:trac11, class_name: :trac) do
  target "message"
  action "plane"
  pre_content "pre "
  post_content " post"
  topic
end

Fabricator(:trac12, class_name: :trac) do
  target "prev"
  action "keyword"
  pre_content "pre "
  post_content " post"
  topic
end

Fabricator(:trac13, class_name: :trac) do
  target "prev"
  action "news"
  pre_content "pre "
  post_content " post"
  topic
end
