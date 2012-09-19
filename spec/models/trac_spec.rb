# -*- coding: utf-8 -*-
require 'spec_helper'

describe Trac do
  before(:each) do
    user = User.create({fb_id: "1", name: "user_name"})
    channel = user.channels.create({name: "channel_name"})
    @topic = channel.topics.create({name: "topic_name", order:1 ,target: "target"})
  end

  describe "the action" do
    it "can not be nil" do
      trac = @channel.tracs.build({target: "target"})
      trac.should_not be_valid
    end
  end

  describe "the target" do
    it "can not be nil" do
      trac = @channel.tracs.build({action: "action"})
      trac.should_not be_valid
    end
  end

  describe "the pre_content" do
    it "can be nil" do
      trac = @channel.tracs.build({action: "action", target: "target"})
      trac.should be_valid
    end

    it "can be less than 101 characters" do
      trac = @channel.tracs.build({action: "action", target: "target", pre_content: "a" * 100})
      trac.should be_valid
    end

    it "can not be more than 100 characters" do
      trac = @channel.tracs.build({action: "action", target: "target", pre_content: "a" * 101})
      trac.should_not be_valid
    end
  end

  describe "the post_content" do
    it "can be nil" do
      trac = @channel.tracs.build({action: "action", target: "target"})
      trac.should be_valid
    end

    it "can be less than 101 characters" do
      trac = @channel.tracs.build({action: "action", target: "target", post_content: "a" * 100})
      trac.should be_valid
    end

    it "can not be more than 100 characters" do
      trac = @channel.tracs.build({action: "action", target: "target", post_content: "a" * 101})
      trac.should_not be_valid
    end
  end

end
