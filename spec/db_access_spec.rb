require "spec_helper"

describe MachiKoro::DBAccess do
  let(:db) { MachiKoro::DBAccess.new }
  context "get establishment" do
    it "should return wheat field by name" do
      data = db.get_establishment("Wheat Field")
      expect(data["description"].to_s).to eq ("Wheat Field")
    end
    it "should return cheese factory by number" do
      data = db.get_establishment(11)
      expect(data["description"].to_s).to eq ("Cheese Factory")
    end
    it "returns false if no record found" do
      data = db.get_establishment("Not a card name")
      expect(data).to eq(false)
    end
  end
  
  context "get all establishments" do
    let(:data) {db.get_all_establishments}
    it "returns an array" do
      expect(data).to be_a(Array)
    end
    it "should return all 20 establishments" do
      expect(data.length).to be(20)
    end
  end
end