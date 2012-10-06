# -*- coding: utf-8 -*-
require 'spec_helper'

# このスコープで再定義しないとダメみたい なぜだ beforeで書きたいのに
def open(uri)
  return "<Result>__relation__</Result>"
end

describe Story do
  before do
    class FbMock
      class MessageMock
        class FromMock
          def initialize(name)
            @name = name
          end

          def name
            return @name
          end
        end

        def initialize(msg)
          @msg = msg
        end

        def message
          return @msg
        end

        def from
          return FromMock.new("__from.name__")
        end
      end

      def home
        return [MessageMock.new("__home_message__")]
      end

      def feed
        return [MessageMock.new("__feed_message__")]
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
          ["__keyphrase__"]
        end
        return extracted
      end
    end

    def YoutubeSearch.search(str)
      return [{"video_id" => "__video_id__"}]
    end

    def SimpleRSS.parse(val)
      rss = Object.new

      def rss.entries
        entry = Object.new

        def entry.title
          return "__news__"
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
    context "with a right channel_id which contains a topic about 'feed'" do
      before do
        user = Fabricate(:user)
        @channel = Fabricate(:channel, user: user)
        topic = Fabricate(:topic00, channel: @channel)
        Fabricate(:track00, topic: topic)
        Fabricate(:track01, topic: topic)
        Fabricate(:track02, topic: topic)
        Fabricate(:track03, topic: topic)
      end

      it "returns an array which has some Hashes" do
        json = Story.get(FbMock.new, @channel.id)

        json.class.should == Hash

        json[:metadata].should_not be_nil
        json[:metadata][:hash].should_not be_nil

        contents = json[:content]
        contents.class.should == Array
        contents.should have(4).items

        contents[0][:text].should == "pre __feed_message__ post"
        contents[1][:text].should == "pre __keyphrase__ post"
        contents[2][:text].should == "pre __relation__ post"
        contents[3][:text].should == "pre __news__ post"
      end
    end

    context "with a right channel_id which contains a topic about 'home'" do
      before do
        user = Fabricate(:user)
        @channel = Fabricate(:channel, user: user)
        topic = Fabricate(:topic01, channel: @channel)
        Fabricate(:track10, topic: topic)
        Fabricate(:track11, topic: topic)
        Fabricate(:track12, topic: topic)
        Fabricate(:track13, topic: topic)
      end

      it "returns an array which has some Hashes" do
        json = Story.get(FbMock.new, @channel.id)

        json.class.should == Hash

        json[:metadata].should_not be_nil
        json[:metadata][:hash].should_not be_nil

        contents = json[:content]
        contents.class.should == Array
        contents.should have(4).items

        contents[0][:text].should == "pre __from.name__ post"
        contents[1][:text].should == "pre __home_message__ post"
        contents[2][:text].should == "pre __keyphrase__ post"
        contents[3][:text].should == "pre __news__ post"
      end
    end

    context "with a wrong channel_id" do
      before do
        @undefined_channel_id = 1
      end

      subject { lambda { Story.get(FbMock.new, @undefined_channel_id) } }
      it { should raise_error }
    end

    context "with a channel_id which has no tracks" do
      before do
        user = Fabricate(:user)
        @channel = Fabricate(:channel, user: user)
        topic = Fabricate(:topic00, channel: @channel)
      end

      subject { lambda { Story.get(FbMock.new, @channel.id) } }
      it { should raise_error }
    end
  end

  describe Story::TrackReader do
    describe "plane" do
      before(:each) do
        @reader = Story::TrackReader.new
      end

      it "returns text without change which does not contain any URL" do
        input = "hoge"
        @reader.plane(input).text.should == input
      end

      it "returns text and link which contains a URL" do
        uri = "http://hoge.com/a/b.html?c=d#e"
        input = "foo #{uri} bar"
        track = @reader.plane(input)
        track.text.should == "foo  bar"
        track.link.should == [uri]
      end

      it "returns text and link which contains some URLs" do
        uri1 = "http://hoge.com/a/b.html?c=d#e1"
        uri2 = "http://hoge.com/a/b.html?c=d#e2"
        input = "foo #{uri1} bar foo #{uri2} bar"
        track = @reader.plane(input)
        track.text.should == "foo  bar foo  bar"
        track.link.should == [uri1, uri2]
      end
    end

    describe "news" do
      before(:each) do
        @reader = Story::TrackReader.new
      end

      it "extracts actual URL from Google NEWS fomat URL to redirect" do
        news = Story::TrackReader.new.news("test")
        news.link.should == ["http://foo.com/bar.html?id=001"]
      end
    end
  end

  describe Story::StructuredTrack do
    before do
      @track = Story::StructuredTrack.new
    end

    describe "to_hash" do
      it "convert text attribute to hash" do
        @track.text = "foo"
        @track.to_hash.should == {text: "foo"}
      end

      it "convert link attribute to hash" do
        @track.link = "foo"
        @track.to_hash.should == {link: "foo"}
      end

      it "convert video attribute to hash" do
        @track.video = "foo"
        @track.to_hash.should == {video: "foo"}
      end

      it "do not convert text_decoration_flag attribute to hash" do
        @track.text_decoration_flag = false
        @track.to_hash.should == {}
      end

      it "convert text, link and video attribute to hash" do
        @track.text = "t"
        @track.link = "l"
        @track.video = "v"
        @track.text_decoration_flag = true
        @track.to_hash.should == {text: "t", link: "l", video: "v"}
      end
    end
  end
end
