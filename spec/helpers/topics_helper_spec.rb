# -*- coding: utf-8 -*-
require 'spec_helper'

include TopicsHelper

describe TopicsHelper do
  describe "get_topic_target_choices" do
    it "returns an array which has some elements" do
      topic_targets = TopicsHelper.get_topic_target_choices(Topic.new)

      topic_targets.class.should == Array
      topic_targets.should have_at_least(1).items
      topic_targets.each do |item|
        item.has_key?(:value).should == true
        item.has_key?(:label).should == true
        item.keys.should have(2).items
      end
    end
  end

  describe "get_trac_target_choices" do
    it "returns an array which has some elements" do
      trac_targets = TopicsHelper.get_trac_target_choices(Topic.new)

      trac_targets.class.should == Array
      trac_targets.should have_at_least(1).items
      trac_targets.each do |item|
        item.should have(2).items
        item[0].class.should == String
        item[1].class.should == String
      end
    end
  end

  describe "get_trac_action_choices" do
    it "returns an array which has some elements" do
      trac_actions = TopicsHelper.get_trac_action_choices

      trac_actions.class.should == Array
      trac_actions.should have_at_least(1).items
      trac_actions.each do |item|
        item.should have(2).items
        item[0].class.should == String
        item[1].class.should == String
      end
    end
  end
end

