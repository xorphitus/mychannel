require 'spec_helper'

describe User do
  describe "the name" do
    it "can not be nil" do
      user = User.new({})
      user.should_not be_valid
    end
    it "can be less than 20 chars" do
      user = User.new({name: "a" * 21})
      user.should_not be_valid
    end
  end
end
