# -*- coding: utf-8 -*-
require 'spec_helper'

describe Array do

  context "when empty" do
    subject { [].rand }
    it { should be_nil }
  end

  context "when an Array has just one element" do
    subject { ["the only element"].rand }
    it { should == "the only element" }
  end

end

describe Story do

  before do
    class StringExt < String
      def method_missing(name, *args)
        name.to_s
      end
    end

    class FbUserMock
      def method_missing(name, *args)
        [StringExt.new(name.to_s)]
      end
      def message
        "message"
      end
    end

    yahoo = Settings.yahoo
    def yahoo.app_id
      "app_id"
    end
    module YaCan::Keyphrase
      def extract(str)
        extracted = Object.new
        def extracted.phrases
          ["keyphrase"]
        end
        extracted
      end
    end

    def YoutubeSearch.search(str)
      [{"video_id" => "video_id"}]
    end

    def open(uri)
      "<foo></foo>"
    end
    def SimpleRSS.parse(val)
      rss = Object.new
      def rss.entries
        entry = Object.new
        def entry.title
          "hoge news"
        end
        def entry.link
          "http://news.google.com/news/url?sa=t&amp;fd=R&amp;usg=AFQjCNECYBnagl1AD2mcN5hRdE4w8pGdbA&amp;url=http://foo.com/bar.html?id%3D001"
        end
        [entry]
      end
      rss
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

  describe TracReader do

    describe "plane" do
      before(:each) do
        @reader = TracReader.new
      end

      it "returns text without change which does not contain any URL" do
        input = "hoge"
        @reader.plane(input).text.should == input
      end

      it "returns text and link which contains a URL" do
        uri = "http://hoge.com/a/b.html?c=d#e"
        input = "foo #{uri} bar"
        trac = @reader.plane(input)
        trac.text.should == "foo  bar"
        trac.link.should == [uri]
      end

      it "returns text and link which contains some URLs" do
        uri1 = "http://hoge.com/a/b.html?c=d#e1"
        uri2 = "http://hoge.com/a/b.html?c=d#e2"
        input = "foo #{uri1} bar foo #{uri2} bar"
        trac = @reader.plane(input)
        trac.text.should == "foo  bar foo  bar"
        trac.link.should == [uri1, uri2]
      end
    end

    describe "news" do
      before(:each) do
        @reader = TracReader.new
      end

      it "extracts actual URL from Google NEWS fomat URL to redirect" do
        news = TracReader.new.news("test")
        news.link.should == ["http://foo.com/bar.html?id=001"]
      end
    end

  end

  describe StructuredTrac do
    before do
      @trac = StructuredTrac.new
    end

    describe "to_hash" do
      it "convert text attribute to hash" do
        @trac.text = "foo"
        @trac.to_hash.should == {text: "foo"}
      end

      it "convert link attribute to hash" do
        @trac.link = "foo"
        @trac.to_hash.should == {link: "foo"}
      end

      it "convert video attribute to hash" do
        @trac.video = "foo"
        @trac.to_hash.should == {video: "foo"}
      end

      it "do not convert text_decoration_flag attribute to hash" do
        @trac.text_decoration_flag = false
        @trac.to_hash.should == {}
      end

      it "convert text, link and video attribute to hash" do
        @trac.text = "t"
        @trac.link = "l"
        @trac.video = "v"
        @trac.text_decoration_flag = true
        @trac.to_hash.should == {text: "t", link: "l", video: "v"}
      end
    end

  end

end
