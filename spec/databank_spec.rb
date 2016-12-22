require "spec_helper"
require_relative "../lib/machi_koro/databank.rb" #needed for Establishment

describe MachiKoro::Databank do
  let(:db) { MachiKoro::Databank.new }
  context "load all establishments" do
    let(:all_establishments) { db.establishments }
    it "should return an Array" do
      expect(all_establishments).to be_a_kind_of (Array)
    end
    it "should only contain Establishments" do
      expect(all_establishments).to all( be_an(MachiKoro::Establishment))
    end
  end
  context "load all landmarks" do
    let(:all_landmarks) { db.landmarks }
    it "should return an Array" do
      expect(all_landmarks).to be_a_kind_of (Array)
    end
    it "should only contain Landmarks" do
      expect(all_landmarks).to all( be_an(MachiKoro::Landmark))
    end
  end
end

describe MachiKoro::Establishment do
  wf_data = { "id" => 1, 
              "description" => "Wheat Field", 
              "effect" => "1 coin on anyone's turn", 
              "from_roll" => "1", 
              "to_roll" => "1", 
              "base_income" => "1", 
              "colour" => "blue", 
              "symbol" => "grain", 
              "expansion" => "Original"
            }
  let(:wf) { MachiKoro::Establishment.new(wf_data) }
  context "A wheat field" do
    it "is blue colour" do
      expect(wf.attribute[:colour]).to eq(:blue)
    end
    it "activates on own turn when 1 is rolled" do
      expect(wf.is_activated roll=1, owners_turn=true).to eq(true)
    end
    it "activates on other's turn when 1 is rolled" do
      expect(wf.is_activated roll=1, owners_turn=false).to eq(true)
    end
    it "does not activate on a 2" do
      expect(wf.is_activated roll=2, owners_turn=true).to eq(false)
      expect(wf.is_activated roll=2, owners_turn=false).to eq(false)
    end
    it "displays its roll range as 1" do
      expect(wf.roll_range).to eq("1")
    end
    it "has an id of the expected type and value" do
      expect(wf.id).to eq(1)
      expect(wf.id).to be_a_kind_of(Integer)
    end
  end
  
  red_card_data = Hash.new("bob")
  red_card_data["colour"] = "red"
  red_card_data["from_roll"] = 2
  red_card_data["to_roll"] = 3
  let(:red_card) { MachiKoro::Establishment.new(red_card_data) }
  context "A red card" do
    it "does not activate on own turn" do
      expect(red_card.is_activated roll=3, owners_turn=true).to eq(false)
    end
    it "does activate on other people's turn" do
      expect(red_card.is_activated roll=3, owners_turn=false).to eq(true)
    end
  end
  
  green_card_data = Hash.new("bob")
  green_card_data["colour"] = "green"
  green_card_data["from_roll"] = 5
  green_card_data["to_roll"] = 5
  let(:green_card) { MachiKoro::Establishment.new(green_card_data) }
  context "A green card" do
    it "does activate on own turn" do
      expect(green_card.is_activated roll=5, owners_turn=true).to eq(true)
    end
    it "does not activate on other people's turn" do
      expect(green_card.is_activated roll=5, owners_turn=false).to eq(false)
    end
  end
 end

  
  
  
describe MachiKoro::Landmark do
  lm_data = { "id" => 1, 
              "description" => "Harbour", 
              "effect" => "It has an effect",
              "harbour" => "1", 
              "two_dice" => 0,
              "expansion" => "Harbour",
              "cost" => "2",
              "pre_built" => false
            }
  let(:lm) { MachiKoro::Landmark.new(lm_data) }
  context "A harbour" do
    it "costs 2" do
      expect(lm.cost).to eq(2)
    end
    it "has the harbour ability and no others" do
      expect(lm.ability).to contain_exactly(:harbour)
    end
    it "is called a harbour" do
      expect(lm.name).to eq("Harbour")
    end
    it "is from the harbour expansion" do
      expect(lm.expansion).to eq(:harbour)
    end
    it "is not pre-built" do
      expect(lm.pre_built).to eq(false)
    end
  end
end