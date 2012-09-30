# -*- coding: utf-8 -*-
require 'spec_helper'

# このスコープで再定義しないとダメみたい なぜだ beforeで書きたいのに
def open(uri)
  return "<foo></foo>"
end

describe Story do
  before do
    class FbMock
      class MessageMock
        def initialize(msg)
          @msg = msg
        end

        def message
          return @msg
        end
      end

      def home
        return [MessageMock.new("home")]
      end

      def feed
        return [MessageMock.new("feed")]
      end
    end

    yahoo = Settings.yahoo
    def yahoo.app_id
      return "app_id"
    end

    module YaCan::Keyphrase
      def self.extract(str)
        extracted = Object.new
        def extracted.phrases
          ["keyphrase"]
        end
        return extracted
      end
    end

    def YoutubeSearch.search(str)
      return [{"video_id" => "video_id"}]
    end

    def SimpleRSS.parse(val)
      rss = Object.new

      def rss.entries
        entry = Object.new

        def entry.title
          return "hoge news"
        end

        def entry.link
          return "http://news.google.com/news/url?sa=t&amp;fd=R&amp;usg=AFQjCNECYBnagl1AD2mcN5hRdE4w8pGdbA&amp;url=http://foo.com/bar.html?id%3D001"
        end
        return [entry]
      end
      return rss
    end
  end

  describe "get" do
    context "with a right channel_id" do
      before do
        user = Fabricate(:user)
        @channel = Fabricate(:channel, user: user)
        topic = Fabricate(:topic, channel: @channel)
        Fabricate(:trac01, topic: topic)
        Fabricate(:trac02, topic: topic)
        Fabricate(:trac03, topic: topic)
        Fabricate(:trac04, topic: topic)
      end

      it "returns an array which has some Hashes" do
        json = Story.get(FbMock.new, @channel.id)

        json.class.should == Array
        json.should have(4).items
        json.each do |item|
          item.class.should == Hash
        end
      end
    end

    context "with a wrong channel_id" do
      before do
        @undefined_channel_id = 1
      end

      subject { lambda { Story.get(FbMock.new, @undefined_channel_id) } }
      it { should raise_error }
    end

    context "with a channel_id which has no tracs" do
      before do
        user = Fabricate(:user)
        @channel = Fabricate(:channel, user: user)
        topic = Fabricate(:topic, channel: @channel)
      end

      subject { lambda { Story.get(FbMock.new, @channel.id) } }
      it { should raise_error }
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
