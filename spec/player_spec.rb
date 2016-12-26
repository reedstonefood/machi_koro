require "spec_helper"
require_relative "../lib/machi_koro/player.rb"
require_relative "../lib/machi_koro/databank.rb"

describe MachiKoro::Player do
  let (:harbour_card) { MachiKoro::Landmark.new({ "id" => 1, 
              "description" => "Harbour", 
              "effect" => "It has an effect",
              "harbour" => "1", 
              "two_dice" => 0,
              "expansion" => "Harbour",
              "cost" => "2",
              "pre_built" => false
            })}
  let (:p) { MachiKoro::Player.new("Dave", 2, "x", \
              Array[harbour_card], nil) }
  it "has a name" do
    expect(p.name).to eq("Dave")
  end
  it "has 3 money" do
    expect(p.money).to eq(3)
  end
  it "has a position in the turn order" do
    expect(p.turn_order).to eq(2)
  end
  it "built landmarks = size 1 array containing a Landmark" do
    expect(p.built_landmarks).to be_a_kind_of(Array)
    expect(p.built_landmarks.count).to eq(1)
    expect(p.built_landmarks[0]).to be_a_kind_of(MachiKoro::Landmark)
  end
  it "confirms it has harbour ability" do
    expect(p.has_ability(:harbour)).to eq(true)
  end
  it "confirms it does NOT has reroll ability" do
    expect(p.has_ability(:reroll)).to eq(false)
  end
end