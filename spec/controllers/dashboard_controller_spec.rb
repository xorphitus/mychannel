# -*- coding: utf-8 -*-
require 'spec_helper'

describe DashboardController do
  before do
    class DashboardController
      attr_accessor :channel_list
    end
  end

  describe "index" do
    before do
      me_json = File.new(Rails.root.join("spec/models/fb_me.json"))
      WebMock.stub_request(:get, /graph\.facebook\.com\/me/) .to_return(body: me_json)

      user = Fabricate(:user)
      channel = Fabricate(:channel, user: user)

      @controller = DashboardController.new
    end

    it "assigns pairs of name and ID number to channel_list" do
      @controller.index
      @controller.channel_list.each do |channel|
        channel.size.should == 2
        channel[0].class.should == String
        channel[1].class.should == Fixnum
      end
    end
  end
end
