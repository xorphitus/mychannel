# -*- coding: utf-8 -*-
require 'spec_helper'

describe VoicesController do
  describe String do
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

  describe "emit" do
    before do
      def Voice.get(text)
        return text
      end

      class VoicesController
        def initialize(text)
          @text = text
        end

        def params
          return {text: @text}
        end

        def send_data(voice, header)
          return voice
        end
      end
    end

    subject { VoicesController.new("テスト    hoge てすと").emit }
    it { should == "テスト,ホゲ,てすと" }
  end
end
