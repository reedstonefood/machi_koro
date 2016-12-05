require_relative 'db_access'
require 'json'
#http://stackoverflow.com/questions/2070010/how-to-output-my-ruby-commandline-text-in-different-colours
#with help for other colours from...
#http://stackoverflow.com/questions/2616906/how-do-i-output-coloured-text-to-a-linux-terminal
class Colours
   COLOR1 = "\e[1;36;40m"
   COLOR2 = "\e[1;35;40m"
   NOCOLOR = "\e[0m"
   RED = "\e[1;31;40m"
   GREEN = "\e[1;32;40m"
   BLUE = "\e[1;34;40m"
   MAGENTA = "\e[1;35;40m"
   DARKGREEN = "\e[0;32;40m"
   YELLOW = "\e[1;33;40m"
   DARKCYAN = "\e[0;36;40m"
end

class String
   def colour(colour)
      return colour + self + Colours::NOCOLOR if !colour.nil?
      self
   end
end

  
module MachiKoro

  class Establishment
  
    attr_reader :attribute, :id
  
    def initialize(data)
      @attribute = Hash.new()
      @id = data["id"].to_i
      @attribute["name"] = data["description"]
      @attribute["effect"] = data["effect"]
      @attribute["cost"] = data["cost"].to_i
      @attribute["from_roll"] = data["from_roll"].to_i
      @attribute["to_roll"] = data["to_roll"].to_i
      @attribute["base_income"] = data["base_income_value"].to_i
      
      #TODO id's that will activate the building
      
      @attribute["colour"] = data["colour"].downcase.to_sym
      @attribute["symbol"] = data["symbol"].downcase.to_sym #haha
      @attribute["expansion"] = data["expansion"].downcase.to_sym
      @attribute["alternative_income_method"] = data["alternative_income_method"].to_sym if !data["alternative_income_method"].nil? # line too long?
    end
    
    def to_json
      @attribute.to_json
    end
    
    def is_activated(roll, owners_turn)
      return false if !(@attribute["from_roll"] <= roll && @attribute["to_roll"] >= roll)
      return true if @attribute["colour"] == :blue
      return true if @attribute["colour"] == :green && owners_turn
      return true if @attribute["colour"] == :red && !owners_turn
      false # a catch-all... shouldn't really happen
    end
    
    def justified_effect
      return @justified_effect if defined? @justified_effect
      @justified_effect = Array.new
      strlen, i = 0, 0
      @attribute['effect'].split.each do |word|
        if strlen > 25 #can these 4 lines be shortened to one?
          i += 1
          strlen = 0
        end
        @justified_effect[i] = '' if @justified_effect[i].nil?
        @justified_effect[i] << word + ' '
        strlen += word.length + 1
      end
      5.times { @justified_effect << '' } #ensures no Nil elements
      @justified_effect.collect { |line| line.chop }
    end
    
    def je; self.justified_effect; end
    
    def roll_range
      #this COULD be done on one line... but it would have poor readability
      if @attribute["from_roll"] == @attribute["to_roll"]
        return @attribute["from_roll"].to_s
      end
      "#{@attribute["from_roll"]}-#{@attribute["to_roll"]}"
    end
    
    def console_output
      w = 36 # width of "card"
      str = '*' * (w+2) + "\n"
      str << '*' << self.roll_range.center(w) << "* #{je[0]}\n"
      str << '*' << @attribute["name"].capitalize.center(w) << "* #{je[1]}\n"
      str << '*' << " Symbol : #{@attribute["symbol"]} ".center(w) << "* #{je[2]}\n"
      str << '*' << " Cost : #{@attribute["cost"]} ".center(w) << "* #{je[3]}\n"
      str << '*' * (w+2) << " #{je[4]}"
      puts str.colour(ansi_colour)
    end
    
    private
    def ansi_colour
      case @attribute["colour"]
        when :red
          Colours::RED
        when :blue
          Colours::BLUE
        when :green
          Colours::GREEN
        when :purple
          Colours::MAGENTA
      end
    end
  end
  
  
  class Databank
  

    def initialize
      @db = DBAccess.new
    end

    def establishments
      return @establishments if defined? @establishments
      @establishments = Array.new()
      @db.get_all_establishments.each do |data|
        @establishments << MachiKoro::Establishment.new(data)
      end
      @establishments
    end
    
  end
  
end