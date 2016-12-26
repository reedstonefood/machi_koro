require "spec_helper"
require_relative "../lib/machi_koro/game.rb"

describe MachiKoro::Game do
  let (:g) { MachiKoro::Game.new }
  context "When adding a player called Bob" do
    before { g.add_player("Bob") }
      it "first player is called Bob" do
        expect(g.players[0].name).to eq("Bob")
      end
      it "player should have a tableau of 2 cards" do
        expect(g.players[0].tableau.deck_size).to eq(2)
      end
      it "should have one built landmark (City Hall)" do
        expect(g.players[0].built_landmarks.size).to eq(1)
        expect(g.players[0].built_landmarks[0].name).to eq("City Hall")
      end
      it "should have six unbuilt landmarks" do
        expect(g.players[0].unbuilt_landmarks.size).to eq(6)
      end
    end
  context "the town" do
    it "should have 10 different piles" do
      expect(g.town.distinct_count).to eq (10)
    end
    it "should be a Tableau" do
      expect(g.town).to be_a_kind_of(MachiKoro::Tableau)
    end
  end
  context "the stockpile" do
    it "be a Tableau" do
      expect(g.stockpile).to be_a_kind_of(MachiKoro::Tableau)
    end
  end
end