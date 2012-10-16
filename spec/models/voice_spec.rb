# -*- coding: utf-8 -*-
require 'spec_helper'

describe Voice do
  describe "limit" do
    context "without suffix" do
      context "string size is smaller than limit" do
        subject { Voice.limit("1234", 10, nil) }
        it { should == "1234" }
      end

      context "string size is equal to limit" do
        subject { Voice.limit("1234", 10, nil) }
        it { should == "1234" }
      end

      context "string size is larger than limit" do
        subject { Voice.limit("1234", 3, nil) }
        it { should == "123" }
      end
    end

    context "with suffix" do
      context "string size is smaller than limit" do
        subject { Voice.limit("1234", 10, "_suf") }
        it { should == "1234" }
      end

      context "string size is equal to limit" do
        subject { Voice.limit("1234", 4, "_suf") }
        it { should == "1234" }
      end

      context "string size is larger than limit" do
        subject { Voice.limit("1234567890", 8, "_suf") }
        it { should == "12345_suf" }
      end
    end
  end

  describe "adjust_text" do
    subject { Voice.adjust_text("テスト    hoge てすと") }
    it { should == "テスト,ホゲ,てすと" }
  end
end
