# -*- coding: utf-8 -*-
require 'spec_helper'

describe VoicesController do
  describe String, "extended for VoicesController" do
    describe "limit" do
      context "without suffix" do
        context "string size is smaller than limit" do
          subject { "1234".limit(10, nil) }
          it { should == "1234" }
        end

        context "string size is equal to limit" do
          subject { "1234".limit(10, nil) }
          it { should == "1234" }
        end

        context "string size is larger than limit" do
          subject { "1234".limit(3, nil) }
          it { should == "123" }
        end
      end

      context "with suffix" do
        context "string size is smaller than limit" do
          subject { "1234".limit(10, "_suf") }
          it { should == "1234" }
        end

        context "string size is equal to limit" do
          subject { "1234".limit(4, "_suf") }
          it { should == "1234" }
        end

        context "string size is larger than limit" do
          subject { "1234567890".limit(8, "_suf") }
          it { should == "12345_suf" }
        end
      end
    end
  end

  describe "adjust_text" do
    subject { VoicesController.new().adjust_text("テスト    hoge てすと") }
    it { should == "テスト,ホゲ,てすと" }
  end
end
