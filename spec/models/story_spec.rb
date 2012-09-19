# -*- coding: utf-8 -*-
require 'spec_helper'

describe Array do
  describe "rand" do
    it "returns nil when it has no elements" do
      [].rand.should be_nil
    end

    it "returns the same when it has just one element" do
      ["ok"].rand.should == "ok"
    end
  end
end

describe Story do
  before do
    class FbTargetMock
      def method_missing(name, *args)
        name.to_s
      end
    end

    class FbUserMock
      def method_missing(name, *args)
        [FbTargetMock.new]
      end
      def message
        "message"
      end
    end

    class TracReader
      instance_methods.each do |m|
        undef_method(m)
      end
      def method_missing(name, *args)
        name.to_s
      end
    end
  end

  describe "get_default_topics" do
    it "returns an array which has some Topics" do
      topics = Story.get_default_topics

      topics.class.should == Array
      topics.should have_at_least(1).items
      topics.each do |topic|
        topic.class.should == Topic
      end
    end
  end

  describe "get" do
    it "returns an array which has some Hashes" do
      json = Story.get(FbUserMock.new, nil)

      json.class.should == Array
      json.should have_at_least(1).items
      json.each do |item|
        item.class.should == Hash
      end
    end
  end
end
