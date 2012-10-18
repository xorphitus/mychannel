# -*- coding: utf-8 -*-
require 'spec_helper'

describe Topic do
  before do
    def to_file(filename)
      File.new(Rails.root.join("spec/webmocks/" + filename))
    end

    WebMock.stub_request(:get, /search\.yahooapis\.jp\/AssistSearchService/).to_return(body: to_file("relation.xml"))
    WebMock.stub_request(:post, /jlp\.yahooapis\.jp\/KeyphraseService/).to_return(body: to_file("keyphrase.xml"))
    WebMock.stub_request(:get, /news\.google\.com/).to_return(body: to_file("news.xml"))
    WebMock.stub_request(:get, /gdata\.youtube\.com/).to_return(body: to_file("video.xml"))
    WebMock.stub_request(:get, /graph\.facebook\.com\/me\/feed/).to_return(body: to_file("fb_feed.json"))
    WebMock.stub_request(:get, /graph\.facebook\.com\/me\/home/).to_return(body: to_file("fb_home.json"))
  end

  describe "to_story" do
    let(:user) { Fabricate(:user) }

    context "with a right channel_id which contains a topic about 'feed'" do
      let(:channel) { Fabricate(:channel, user: user) }

      before do
        topic = Fabricate(:topic00, channel: channel)
        Fabricate(:track00, topic: topic)
        Fabricate(:track01, topic: topic)
        Fabricate(:track02, topic: topic)
        Fabricate(:track03, topic: topic)
      end

      it "returns an array which has some Hashes" do
        json = Topic.to_story(FbGraph::User.me(nil), channel.id)

        json.should be_an_instance_of Hash

        json[:metadata].should_not be_nil
        json[:metadata][:hash].should_not be_nil

        contents = json[:contents]
        contents.should be_an_instance_of Array
        contents.should have(4).items

        contents[0][:text].should == "pre __feed_message__ post"
        contents[1][:text].should == "pre __keyphrase__ post"
        contents[2][:text].should == "pre __relation__ post"
        contents[3][:text].should == "pre __news__ post"
      end
    end

    context "with a right channel_id which contains a topic about 'home'" do
      let(:channel) { Fabricate(:channel, user: user) }

      before do
        topic = Fabricate(:topic01, channel: channel)
        Fabricate(:track10, topic: topic)
        Fabricate(:track11, topic: topic)
        Fabricate(:track12, topic: topic)
        Fabricate(:track13, topic: topic)
      end

      it "returns an array which has some Hashes" do
        json = Topic.to_story(FbGraph::User.me(nil), channel.id)

        json.should be_an_instance_of Hash

        json[:metadata].should_not be_nil
        json[:metadata][:hash].should_not be_nil

        contents = json[:contents]
        contents.should be_an_instance_of Array
        contents.should have(4).items

        contents[0][:text].should == "pre __from.name__ post"
        contents[1][:text].should == "pre __home_message__ post"
        contents[2][:text].should == "pre __keyphrase__ post"
        contents[3][:text].should == "pre __news__ post"
      end
    end

    context "with a wrong channel_id" do
      let(:undefined_channel_id) { 1 }
      subject { lambda { Topic.to_story(FbGraph::User.me(nil), undefined_channel_id) } }
      it { should raise_error }
    end

    context "with a channel_id which has no tracks" do
      let(:channel) { Fabricate(:channel, user: user) }
      before { Fabricate(:topic00, channel: channel) }
      subject { lambda { Topic.to_story(FbGraph::User.me(nil), channel.id) } }
      it { should raise_error }
    end
  end

  describe Topic::TrackReader do
    let(:reader) { Topic::TrackReader.new }

    describe "plane" do
      it "returns text without change which does not contain any URL" do
        input = "hoge"
        reader.plane(input).text.should == input
      end

      it "returns text and link which contains a URL" do
        uri = "http://hoge.com/a/b.html?c=d#e"
        input = "foo #{uri} bar"
        track = reader.plane(input)
        track.text.should == "foo  bar"
        track.links.should == [uri]
      end

      it "returns text and link which contains some URLs" do
        uri1 = "http://hoge.com/a/b.html?c=d#e1"
        uri2 = "http://hoge.com/a/b.html?c=d#e2"
        input = "foo #{uri1} bar foo #{uri2} bar"
        track = reader.plane(input)
        track.text.should == "foo  bar foo  bar"
        track.links.should == [uri1, uri2]
      end
    end

    describe "news" do
      it "extracts actual URL from Google NEWS fomat URL to redirect" do
        news = reader.news("test")
        news.links.should == ["http://foo.com/bar.html?id=001"]
      end
    end
  end

  describe Topic::StructuredTrack do
    let(:st_track) { Topic::StructuredTrack.new(text, links, video) }
    subject { st_track.to_hash }

    describe "to_hash" do
      context "when only text attribute is set" do
        let(:text) { "foo" }
        let(:links) { nil }
        let(:video) { nil }
        it { should == {text: "foo"} }
      end

      context "when only link attribute is set" do
        let(:text) { nil }
        let(:links) { %w(a b) }
        let(:video) { nil }
        it { should == {links: %w(a b)} }
      end

      context "when only video attribute is set" do
        let(:text) { nil }
        let(:links) { nil }
        let(:video) { "bar" }
        it { should == {video: "bar"} }
      end

      context "when all attributes: text, link and video are set" do
        let(:text) { "t" }
        let(:links) { %w(c d) }
        let(:video) { "v" }
        it { should == {text: "t", links: %w(c d), video: "v"} }
      end
    end
  end
end
