require 'spec_helper'

describe Track do
  describe Track::StructuredTrack do
    describe "to_hash" do
      context "when only text attribute is set" do
        subject{ Track::StructuredTrack.new(text: "foo").to_hash }
        it { should == {text: "foo"} }
      end

      context "when only link attribute is set" do
        subject{ Track::StructuredTrack.new(links: %w(a b)).to_hash }
        it { should == {links: %w(a b)} }
      end

      context "when only video attribute is set" do
        subject{ Track::StructuredTrack.new(video: "bar").to_hash }
        it { should == {video: "bar"} }
      end

      context "when StructuredTrack is missed one" do
        subject { Track::StructuredTrack.missing_track(nil).to_hash }
        it { should == {} }
      end

      context "when all attributes: text, link and video are set" do
        subject{ Track::StructuredTrack.new(text: "t", links: %w(c d), video: "v").to_hash }
        it { should == {text: "t", links: %w(c d), video: "v"} }
      end
    end
  end

  describe Track::TrackReader do
    before do
      def to_file(filename)
        File.new(Rails.root.join("spec/webmocks/" + filename))
      end

      WebMock.stub_request(:get, /search\.yahooapis\.jp\/AssistSearchService/).to_return(body: to_file("relation.xml"))
      WebMock.stub_request(:post, /jlp\.yahooapis\.jp\/KeyphraseService/).to_return(body: to_file("keyphrase.xml"))
      WebMock.stub_request(:get, /news\.google\.com/).to_return(body: to_file("news.xml"))
      WebMock.stub_request(:get, /gdata\.youtube\.com/).to_return(body: to_file("video.xml"))
    end

    describe "plane" do
      it "returns text without change which does not contain any URL" do
        input = "hoge"
        Track::TrackReader.plane(input).text.should == input
      end

      it "returns text and link which contains a URL" do
        uri = "http://hoge.com/a/b.html?c=d#e"
        input = "foo #{uri} bar"
        track = Track::TrackReader.plane(input)
        track.text.should == "foo  bar"
        track.links.should == [uri]
      end

      it "returns text and link which contains some URLs" do
        uri1 = "http://hoge.com/a/b.html?c=d#e1"
        uri2 = "http://hoge.com/a/b.html?c=d#e2"
        input = "foo #{uri1} bar foo #{uri2} bar"
        track = Track::TrackReader.plane(input)
        track.text.should == "foo  bar foo  bar"
        track.links.should == [uri1, uri2]
      end
    end

    describe "news" do
      it "extracts actual URL from Google NEWS fomat URL to redirect" do
        news = Track::TrackReader.news("test")
        news.links.should == ["http://foo.com/bar.html?id=001"]
      end
    end
  end
end
