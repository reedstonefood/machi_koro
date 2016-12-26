require "spec_helper"
require_relative "../lib/machi_koro/turn.rb"
require_relative "../lib/machi_koro/game.rb"

describe MachiKoro::Turn do
  let (:g) { MachiKoro::Game.new()}
  before { g.add_player("Andy")
           g.add_player("Ben")
           g.add_player("Chris")}
  let (:t) { MachiKoro::Turn.new(g, g.players[1])} #Ben

  context "rolling dice: " do
    it "rolling 1 returns a 1-sized array with an Integer" do
      expect(t.roll_dice(1)).to be_a_kind_of(Array)
      expect(t.roll_dice(1).count).to eq(1)
      expect(t.roll_dice(1)).to all(be_a_kind_of(Integer))
    end
    it "rolling 2 returns a 2-sized array with Integers" do
      expect(t.roll_dice(2)).to be_a_kind_of(Array)
      expect(t.roll_dice(2).count).to eq(2)
      expect(t.roll_dice(2)).to all(be_a_kind_of(Integer))
    end
  end
  
  it "activates the correct cards" do
    expect(t.get_cards(1).count).to eq(4)
    expect(t.get_cards(1)[:blue].count).to eq(3)
    expect(t.get_cards(1)[:red].count).to eq(0)
    expect(t.get_cards(1)[:green].count).to eq(0)
    expect(t.get_cards(1)[:purple].count).to eq(0)
  end
  
  context "determining resolution order" do
    let (:r) { t.resolution_order}
    it "has 3 players" do
      expect(g.players.count).to eq(3)
    end
    it "current player is Ben" do
      expect(g.players[1].name).to eq("Ben")
    end
    it "returns reverse order starting with p2" do
      expect(r[0].name).to eq("Ben")
      expect(r[1].name).to eq("Andy")
      expect(r[2].name).to eq("Chris")
    end
  end
  context "activating wheat field" do
    before {(t.process_cards(1))}
    it "Adds 1 coin to everyone" do
      expect(g.players[0].money).to eq(MachiKoro::DEFAULT_MONEY + 1)
      expect(g.players[1].money).to eq(MachiKoro::DEFAULT_MONEY + 1)
      expect(g.players[2].money).to eq(MachiKoro::DEFAULT_MONEY + 1)
    end
  end
  context "activating bakery" do
    before {(t.process_cards(2))}
    it "Adds 1 coin to the person who rolled it only" do
      expect(g.players[0].money).to eq(MachiKoro::DEFAULT_MONEY)
      expect(g.players[1].money).to eq(MachiKoro::DEFAULT_MONEY + 1)
      expect(g.players[2].money).to eq(MachiKoro::DEFAULT_MONEY)
    end
  end
end