require 'spec_helper'

describe Channel do
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

    context "with a channel which contains a topic about 'feed'" do
      let(:channel) { Fabricate(:channel, user: user) }

      before do
        topic = Fabricate(:topic00, channel: channel)
        Fabricate(:track00, topic: topic)
      end

      it "returns JSON data which contains metadata and an array" do
        json = channel.to_story(FbGraph::User.me(nil))

        json.should be_an_instance_of Hash

        json[:metadata].should_not be_nil
        json[:metadata][:hash].should_not be_nil

        contents = json[:contents]
        contents.should be_an_instance_of Array
      end
    end

    context "with a channel which contains a topic about 'home'" do
      let(:channel) { Fabricate(:channel, user: user) }

      before do
        topic = Fabricate(:topic01, channel: channel)
        Fabricate(:track10, topic: topic)
      end

      it "returns JSON data which contains metadata and an array" do
        json = channel.to_story(FbGraph::User.me(nil))

        json.should be_an_instance_of Hash

        json[:metadata].should_not be_nil
        json[:metadata][:hash].should_not be_nil

        contents = json[:contents]
        contents.should be_an_instance_of Array
      end
    end

    context "with a channel which has no topics" do
      let(:channel) { Fabricate(:channel, user: user) }
      subject { lambda { channel.to_story(FbGraph::User.me(nil)) } }
      it { should raise_error }
    end
  end
end
