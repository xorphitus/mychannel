require 'spec_helper'

describe User do

  describe "fb_id (means Facabook User ID)" do
    context "is nil" do
      subject { User.new({name: "test"}) }
      it { should_not be_valid }
    end

    context "is duplicated" do
      before do
        @user = User.create({fb_id: "1", name: "test1"})
      end

      subject { User.new({fb_id: "1", name: "test2"}) }
      it { should_not be_valid }

      after do
        @user.destroy
      end
    end
  end

  describe "name" do
    context "is nil" do
      subject { User.new({fb_id: "test"}) }
      it { should_not be_valid }
    end

    context "is duplicated" do
      before do
        @user = User.create({fb_id: "10", name: "test"})
      end

      subject { User.new({fb_id: "11", name: "test"}) }
      it { should_not be_valid }

      after do
        @user.destroy
      end
    end

    context "has just 20 characters" do
      subject { User.new({fb_id: "20", name: "a" * 20}) }
      it { should be_valid }
    end

    context "has more then 20 characters" do
      subject { User.new({fb_id: "21", name: "a" * 21}) }
      it { should_not be_valid }
    end
  end

end
