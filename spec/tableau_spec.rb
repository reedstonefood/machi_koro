require "spec_helper"
require_relative "../lib/machi_koro/tableau.rb"
require_relative "../lib/machi_koro/databank.rb" #needed for Establishment

describe MachiKoro::Tableau do
  let(:t) { MachiKoro::Tableau.new }
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
  cafe_data = { "id" => 2, 
              "description" => "Cafe", 
              "effect" => "1 coin from other people", 
              "from_roll" => "3", 
              "to_roll" => "3", 
              "base_income" => "1", 
              "colour" => "red", 
              "symbol" => "cup", 
              "expansion" => "Original"
            }
  stadium_data = { "id" => 6, 
              "description" => "Stadium", 
              "effect" => "2 coins from all other players", 
              "from_roll" => "6", 
              "to_roll" => "6", 
              "base_income" => "2", 
              "colour" => "purple", 
              "symbol" => "landmark", 
              "expansion" => "Original"
            }
  let(:wf) { MachiKoro::Establishment.new(wf_data) }
  let(:cafe) { MachiKoro::Establishment.new(cafe_data) }
  let(:stadium) { MachiKoro::Establishment.new(stadium_data) }
  context "an empty tableau" do
    it "has 0 cards to start with" do
      expect(t.deck_size).to eq(0)
    end
    it "returns nil when asked for a random card" do
      expect(t.random_card).to eq(nil)
    end
    it "reports that there are 0 cup symbols" do
      expect(t.symbol_count(:cup)).to eq(0)
    end
  end
  context "has one card (wheat field)" do
    before { t.add_card(wf) }
    it "reports a deck size of 1" do
      expect(t.deck_size).to eq(1)
    end
    it "returns that card when asked for a random one" do
      expect(t.random_card).to eq(wf)
    end
    it "reports as having 1 grain symbol" do
      expect(t.symbol_count(:grain)).to eq(1)
    end
    it "it agrees there is at least 1 wheat field" do
      expect(t.card_exists(wf)).to eq(true)
    end
  end
  context "has 4 cards added and 2 removed" do
    before { t.add_card(wf) 
             t.add_card(wf)
             t.add_card(wf)
             t.remove_card(wf)
             t.add_card(cafe)
             t.remove_card(cafe)
             t.remove_card(cafe) #this shouldn't do anything
    }
    it "reports a deck size of 2" do
      expect(t.deck_size).to eq(2)
    end
    it "reports as having 2 grain symbols" do
      expect(t.symbol_count(:grain)).to eq(2)
    end
    it "reports as having 0 cup symbols" do
      expect(t.symbol_count(:cup)).to eq(0)
    end
    it "it agrees there is at least 1 wheat field" do
      expect(t.card_exists(wf)).to eq(true)
    end
    it "it agrees there are no cafes" do
      expect(t.card_exists(cafe)).to eq(false)
    end
  end
  context "given a wheat field, cafe and stadium" do
    before { t.add_card(wf)
             t.add_card(cafe)
             t.add_card(stadium)
           }
    it "gives wheat field when asked for low random card" do
      expect(t.random_card(1,2)).to eq(wf)
    end
    it "gives cafe when asked for higher non purple random card" do
      expect(t.random_card(3,45)).to eq(cafe)
    end
    it "gives stadium when asked for a purple random card" do
      expect(t.random_card(1,99,true)).to eq(stadium)
    end
  end
end