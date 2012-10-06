# -*- coding: utf-8 -*-
require 'spec_helper'

describe DashboardController do
  before do
    class DashboardController
      attr_accessor :channel_list

      def fb_me
        nil
      end
    end

    def Channel.find(arg0, arg1)
      []
    end
  end

  describe "index" do
    before do
      @controller = DashboardController.new
      @controller.index
    end

    it "assigns pairs of name and ID number to channel_list" do
      @controller.channel_list.each do |channel|
        channel.size.should == 2
        channel[0].class.should == String
        channel[1].class.should == Fixnum
      end
    end
  end
end
