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
end
