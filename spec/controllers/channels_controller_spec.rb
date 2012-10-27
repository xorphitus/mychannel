# -*- coding: utf-8 -*-
require 'spec_helper'

describe ChannelsController do
  describe "index" do
    before do
      me_json = File.new(Rails.root.join("spec/webmocks/fb_me.json"))
      WebMock.stub_request(:get, /graph\.facebook\.com\/me/).to_return(body: me_json)

      Fabricate(:channel, user: Fabricate(:user))
    end

    context "when a request is not authenticated" do
      before { get :index }
      it { response.should_not be_success }
    end

    context "when a request is authenticated" do
      before do
        controller.login_as("foo", "bar")
        get :index
      end

      it { response.should be_success }

      it "assigns pairs of name and ID number to channel_list" do
        assigns[:channel_list].each do |channel|
          channel.size.should == 2
          channel[0].should be_an_instance_of String
          channel[1].should be_an_instance_of Fixnum
        end
      end
    end
  end
end
