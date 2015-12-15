require 'spec_helper'

RSpec.describe Museum do
  describe "attributes on init" do
    before(:all) do
      @museum = Museum.new("Intrepid")
    end
    it "has a name" do
      expect(@museum.name).to eq("Intrepid")
    end
    it "has no partner" do
      expect(@museum.partner).to be_nil
    end
    it "has no preferences" do
      expect(@museum.preferences.size).to eq(0)
    end
    it "has no proposals" do
      expect(@museum.proposals.size).to eq(0)
    end
  end

  describe "#partner_with" do
    before :all do
      @intrepid = Museum.new("Intrepid")
      @mnh = Museum.new("MoMa")
    end

    it "will partner with the museum" do
      @intrepid.partner_with @mnh
      expect(@intrepid.partner).to eq(@mnh)
    end

    it "the other museum will partner with the first museum" do
      @intrepid.partner_with @mnh
      expect(@mnh.partner).to eq(@intrepid)
    end
  end

  describe "#open?" do
    before :all do
      @open = Museum.new("Museum of Natural History")
    end

    it "if the museum doesn't have a partner return true" do
      expect(@open.open?).to be true
    end

    it "if the museum has a partner return false" do
      moma = Museum.new("MoMa")
      @open.partner_with moma
      expect(@open.open?).to be false
    end
  end

  describe "#release_partner" do
    before :all do
      @intrepid = Museum.new("Intrepid")
      @moma = Museum.new("Moma")
    end

    it "will remove the current partner" do
      @intrepid.partner_with @moma
      @intrepid.release_partner

      expect(@intrepid.open?).to be true
    end

    it "will remove itself from it partners slot" do
      @intrepid.partner_with @moma
      @intrepid.release_partner

      expect(@moma.open?).to be true
    end
  end

  describe "#better_match?" do
    it "returns true if the arguement is better than current partner" do
      mnh = Museum.new("Museum of Natural History")
      moma = Museum.new("MoMa")
      intrepid = Museum.new("Intrepid")
      intrepid.preferences = {mnh => 1, moma => 2}
      intrepid.partner_with moma

      expect(intrepid.better_match?(mnh)).to be true
    end

    it "returns false if the arguement is worse than current partner" do
      mnh = Museum.new("Museum of Natural History")
      moma = Museum.new("MoMa")
      intrepid = Museum.new("Intrepid")
      intrepid.preferences = {moma => 1, mnh => 2}
      intrepid.partner_with moma

      expect(intrepid.better_match?(mnh)).to be false
    end
  end

  describe "#respond_to_request" do

    it "return true if museum doesn't have a partner" do
      intrepid = Museum.new("Intrepid")
      whitney = Museum.new("Whitney")
      expect(intrepid.respond_to_request(whitney)).to be true
    end

    it "return true if museum prefers the new partner" do
      mnh = Museum.new("MNH")
      moma = Museum.new("MoMa")
      intrepid = Museum.new("Intrepid")
      whitney = Museum.new("Whitney")
      mnh.preferences = {intrepid => 1, moma => 2, whitney => 3}
      mnh.partner_with moma
      expect(mnh.respond_to_request(intrepid)).to be true
    end

    it "return false if museum prefers current partner" do
      mnh = Museum.new("MNH")
      moma = Museum.new("MoMa")
      intrepid = Museum.new("Intrepid")
      whitney = Museum.new("Whitney")
      mnh.preferences = {intrepid => 1, moma => 2, whitney => 3}
      mnh.partner_with moma
      expect(mnh.respond_to_request(whitney)).to be false
    end
  end
end
