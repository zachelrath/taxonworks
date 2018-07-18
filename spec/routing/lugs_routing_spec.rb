require "rails_helper"

RSpec.describe LugsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/lugs").to route_to("lugs#index")
    end

    it "routes to #new" do
      expect(:get => "/lugs/new").to route_to("lugs#new")
    end

    it "routes to #show" do
      expect(:get => "/lugs/1").to route_to("lugs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/lugs/1/edit").to route_to("lugs#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/lugs").to route_to("lugs#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/lugs/1").to route_to("lugs#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/lugs/1").to route_to("lugs#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/lugs/1").to route_to("lugs#destroy", :id => "1")
    end

  end
end
