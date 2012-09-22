require 'spec_helper'

describe User do

  describe "fb_id (means Facabook User ID)" do
    it "can not be nil" do
      user = User.new({name: "test"})
      user.should_not be_valid
    end

    it "is unique" do
      user1 = User.create({fb_id: "1", name: "test1"})
      user2 = User.new({fb_id: "1", name: "test2"})
      user2.should_not be_valid
    end
  end

  describe "the name" do
    it "is unique" do
      user1 = User.create({fb_id: "1", name: "test"})
      user2 = User.new({fb_id: "2", name: "test"})
      user2.should_not be_valid
    end

    it "can not be nil" do
      user = User.new({fb_id: "1"})
      user.should_not be_valid
    end

    it "can be less than 21 chars" do
      user = User.new({fb_id: "1", name: "a" * 20})
      user.should be_valid
    end

    it "can be less than 20 chars" do
      user = User.new({fb_id: "1", name: "a" * 21})
      user.should_not be_valid
    end
  end

end
