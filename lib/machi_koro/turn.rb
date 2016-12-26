module MachiKoro

  class Turn
  
    def initialize(game, player)
      @g = game
      @p = player
      @g.log.add(__callee__, "A new turn has been created (#{player.name})")
      #@p_abilities = @p.built_landmarks.reduce([]) { |arr, l| arr.concat(l.ability) }
      @reroll_available = @p.has_ability(:reroll)? false : true
    end
    
    def roll_dice(dice_count)
      if (defined? @roll) && @reroll_available == false
        @g.log.add(__callee__, "Someone tried to roll the dice again!")
        return @roll
      end
      if (defined? @roll) && @reroll_available == true
        @reroll_available = false
        @g.log.add(__callee__, "Re-roll selected")
      end
      @roll = Array.new()
      dice_count.times { @roll << rand(6) }
      @g.log.add(__callee__, "The dice were rolled : #{@roll}")
      @roll
    end

    def sum_dice(input = @roll)
      return input.inject(0, :+)# if defined? @roll
      #false
    end

    def resolution_order()
      return @resolution_order if defined? @resolution_order
      @resolution_order = @g.players.reverse
      @resolution_order.rotate!(@resolution_order.index(@p))
    end
    
    # returns a hash of 4 values, one for each colour.
    # each hash is an array of "slots"
    # a slot is an array of the format [card, card_count, player]
    def get_cards(roll_val = @reroll)
      active_slots = Hash[:blue => Array.new(), :green => Array.new(), :red => Array.new(), :purple => Array.new()]
      resolution_order.each do |player|
        @p == player ? curr_player = true : curr_player = false
        player.tableau.deck.each do |slot|
          if slot[0].is_activated(roll_val, curr_player)
            active_slots[slot[0].attribute[:colour]] << (slot << player) 
          end
        end
      end
      return active_slots
    end
    
    def process_cards(roll_val)
      slots = get_cards(roll_val)
      process_blue(slots[:blue])
      process_green(slots[:green])
      process_red(slots[:red])
      process_purple(slots[:purple])
    end
    
    def process_blue(blue_array)
      #curr_player = 0
      blue_array.each do |slot|
        #if curr_player <> slot[2]
        #  curr_player = slot[2]
        #  abilities = curr_player.built_landmarks.reduce([]) { |arr, l| arr.concat(l.ability) }
        #  boosted_symbols = curr_player.built_landmarks.reduce([]) { |arr, l| arr.concat(l.boosted_symbols).flatten }
        #end
        income = slot[0].attribute[:base_income] * slot[1]
        @g.log.add(__callee__, "#{slot[2].name} has #{slot[1]} x #{slot[0].attribute[:name]} = #{income}")
        slot[2].money += income
      end
    end
    
    def process_green(green_array)
      green_array.each do |slot|
        income = slot[0].attribute[:base_income] * slot[1]
        @g.log.add(__callee__,"#{slot[2].name} has #{slot[1]} x #{slot[0].attribute[:name]} = {income}")
        slot[2].money += income
      end
    end
    
    def process_red(red_array)
      red_array.each do |slot|
        income = slot[0].attribute[:base_income] * slot[1]
        income = @p.money if @p.money < income
        @g.log.add(__callee__,"#{slot[2].name} has #{slot[1]} x #{slot[0].attribute[:name]} = #{income} from #{@p.name}")
        slot[2].cash += income
        @p.cash += -income
      end
    end
    
    def process_purple(purple_array)
      #TODO once purple cards are added
    end
    
  end

end