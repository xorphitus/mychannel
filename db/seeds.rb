# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


user = User.create({fb_id: "1", name: "admin"})

channel = user.channels.create!({name: "番組001", publish_flag: true}, without_protection: true)

topic_1 = channel.topics.create!(name: "01", target: "feed", order: 1)
topic_1.tracs.create!(target: "message", action: "plane", pre_content: "あなたの投稿 ", post_content: "")
topic_1.tracs.create!(target: "prev", action: "keyword", pre_content: "「", post_content: "」といえば")
topic_1.tracs.create!(target: "prev", action: "relation", pre_content: "「", post_content: "」ですが")
topic_1.tracs.create!(target: "prev", action: "news", pre_content: "", post_content: " というニュースがあります")

topic_2 = channel.topics.create!(name: "02", target: "home")
topic_2.tracs.create!(target: "from.name", action: "plane", pre_content: "", post_content: "さんからの投稿")
topic_2.tracs.create!(target: "message", action: "plane", pre_content: "", post_content: "")
topic_2.tracs.create!(target: "prev", action: "keyword", pre_content: "「", post_content: "」といえば")
topic_2.tracs.create!(target: "prev", action: "news", pre_content: "", post_content: " というニュースがあります")

topic_3 = channel.topics.create!(name: "03", target: "music", order: 3)
topic_3.tracs.create!(target: "name", action: "plane", pre_content: "あなたのお気に入り ", post_content: "にちなんだ一曲をどうぞ")
topic_3.tracs.create!(target: "prev", action: "youtube", pre_content: "", post_content: "")

