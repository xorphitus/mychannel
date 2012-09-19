require 'spec_helper'

describe Channel do
  before(:each) do
    @user = User.create({fb_id: "1", name: "test"})
  end

  describe "the name" do
    it "can not be nil" do
      channel = @user.channels.new({})
      channel.should_not be_valid
    end

    it "can be less than 21 chars" do
      channel = @user.channels.build({name: "a" * 20})
      channel.should be_valid
    end

    it "can be not be more than 20 chars" do
      channel = @user.channels.build({name: "a" * 21})
      channel.should_not be_valid
    end
  end

  describe "the description" do
    it "can not be less than 101 chars" do
      channel = @user.channels.build({name: "name", description: "a" * 100})
      channel.should be_valid
    end

    it "can not be more than 100 chars" do
      channel = @user.channels.build({name: "name", description: "a" * 101})
      channel.should_not be_valid
    end
  end
end
