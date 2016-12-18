require_relative 'db_access'

module MachiKoro

  class Tableau
    # deck is an array of length two arrays
    # (card_type(Establishment), card_count (Integer))
    # eacof of these pairs is referred to as a slot

    attr_reader :deck, :deck_size
  
    def initialize
      @deck = Array.new()
      @deck_size = 0
    end

    def add_card(new_card)
      slot = @deck.find { |d| d[0]==new_card}
      if slot.nil?
        @deck << [new_card, 1]
      else
        slot[1] += 1
      end
      @deck_size += 1
    end
    
    def remove_card(new_card)
      slot = @deck.find { |d| d[0]==new_card}
      if !slot.nil?
        slot[1] += -1
        @deck_size += -1
        if slot[1] == 0
          @deck.delete(slot)
        end
      end
    end
    
    def random_card(from_roll = 0, to_roll = 99)
      matching_cards = Array.new()
      #produce an array containing only the rolls that meet the criteria
      if !(from_roll == 0 && to_roll == 99)
        sub_deck = @deck.find_all do |slot|
          slot[0].attribute[:to_roll] >= from_roll && slot[0].attribute[:from_roll] <= to_roll
        end
      else
        sub_deck = @deck
      end
      return nil if sub_deck.length==0
      sub_deck.each { |slot| slot[1].times { matching_cards << slot[0] } }
      matching_cards.sample
    end
    
    def card_exists(searched_card)
      @deck.any? {|slot| slot[0]==searched_card}
    end
    
    def symbol_count(target)
      # for things like "get 2 coin for every wheat"
      @deck.find_all { |s| s[0].attribute[:symbol]==target}.inject(0){ |sum, s| sum + s[1] }
    end
    
    def console_output()
      output = "Contents of tableau\n"
      return output << "EMPTY!" if @deck_size==0
      @deck.each_with_index do |slot, index|
        output << "#{index+1}) #{slot[1]} x #{slot[0].attribute[:name]}\n"
      end
      puts output
    end
    
    def console_choose_card(id)
      return false if id < 1 || id > @deck.length
      return @deck[id-1][0]
    end
  end

end