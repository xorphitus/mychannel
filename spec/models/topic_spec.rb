# -*- coding: utf-8 -*-
require 'spec_helper'

describe Topic do
  before(:each) do
    user = User.create({fb_id: "1", name: "user_name"})
    @channel = user.channels.create({name: "channel_name"})
  end

  describe "the name" do
    it "can not be nil" do
      topic = @channel.topics.build({order: 1, target: "target"})
      topic.should_not be_valid
    end

    it "can be less than 21 characters" do
      topic = @channel.topics.build({name: "a" * 20, order: 1, target: "target"})
      topic.should be_valid
    end

    it "can not be more than 20 characters" do
      topic = @channel.topics.build({name: "a" * 21, order: 1, target: "target"})
      topic.should_not be_valid
    end
  end

  describe "the order" do
    it "can not be nil" do
      topic = @channel.topics.build({name: "name", target: "target"})
      topic.should_not be_valid
    end
  end

  describe "the target" do
    it "can not be nil" do
      topic = @channel.topics.build({order: 1, target: "target"})
      topic.should_not be_valid
    end
  end

  describe "the target text" do
    it "can be nil" do
      topic = @channel.topics.build({name: "name", order: 1, target: "target"})
      topic.should be_valid
    end

    it "can be less than 101 characters" do
      topic = @channel.topics.build({name: "name", order: 1, target: "target", target_text: "a" * 100})
      topic.should be_valid
    end

    it "can not be more than 100 characters" do
      topic = @channel.topics.build({name: "name", order: 1, target: "target", target_text: "a" * 101})
      topic.should_not be_valid
    end
  end

end
