require "spec_helper"

describe ChannelsController do
  describe "routing" do
    scope = "/edit"

    it "routes to #index" do
      get("#{scope}/channels").should route_to("channels#index")
    end

    it "routes to #new" do
      get("#{scope}/channels/new").should route_to("channels#new")
    end

    it "routes to #show" do
      get("#{scope}/channels/1").should route_to("channels#show", :id => "1")
    end

    it "routes to #edit" do
      get("#{scope}/channels/1#{scope}").should route_to("channels#edit", :id => "1")
    end

    it "routes to #create" do
      post("#{scope}/channels").should route_to("channels#create")
    end

    it "routes to #update" do
      put("#{scope}/channels/1").should route_to("channels#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("#{scope}/channels/1").should route_to("channels#destroy", :id => "1")
    end

  end
end
