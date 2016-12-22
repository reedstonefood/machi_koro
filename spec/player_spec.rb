require "spec_helper"
require_relative "../lib/machi_koro/player.rb"

describe MachiKoro::Player do
  let (:p) { MachiKoro::Player.new("Dave", 2, "x", "y", "z") }
  it "has a name" do
    expect(p.name).to eq("Dave")
  end
  it "has 3 money" do
    expect(p.money).to eq(3)
  end
  it "has a position in the turn order" do
    expect(p.turn_order).to eq(2)
  end
end