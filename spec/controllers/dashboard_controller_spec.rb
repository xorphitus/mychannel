# -*- coding: utf-8 -*-
require 'spec_helper'

describe DashboardController do
  before do
    class DashboardController
      def require_authentication
        # 認証を外す / WebMockを使ってもきれいに解決できないため
      end
    end
  end

  describe "index" do
    before do
      me_json = File.new(Rails.root.join("spec/webmocks/fb_me.json"))
      WebMock.stub_request(:get, /graph\.facebook\.com\/me/) .to_return(body: me_json)

      user = Fabricate(:user)
      channel = Fabricate(:channel, user: user)

      get "index"
    end

    it "returns success response" do
      response.should be_success
    end

    it "assigns pairs of name and ID number to channel_list" do
      assigns[:channel_list].each do |channel|
        channel.size.should == 2
        channel[0].should be_an_instance_of String
        channel[1].should be_an_instance_of Fixnum
      end
    end
  end
end
