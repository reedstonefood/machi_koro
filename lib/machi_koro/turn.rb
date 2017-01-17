module MachiKoro

  class DiceRoll
  
    attr_reader :dice_count, :reroll_available, :harbour_available
  
    def initialize(dice_count, reroll_available, harbour_available, log)
      @dice_count = dice_count
      @reroll_available = reroll_available
      @harbour_available = harbour_available
      @log = log
    end
    
    def roll
      if (defined? @dice) && @reroll_available == false
        @log.add(__callee__, "Someone tried to roll the dice again!")
        return @dice
      end
      if (defined? @dice) && @reroll_available == true
        @reroll_available = false
        @log.add(__callee__, "Re-roll selected")
      end
      do_roll
    end
    
    def sum_dice(input = @dice)
      @sum_dice ||= input.inject(0, :+)
    end
    
    def use_harbour
      if @sum_dice >=10 && @harbour_available == true
        @sum_dice += 2
        @harbour_available = false
        @log.add(__callee__, 'Harbour has been activated')
        true
      else # harbour has been used - or player does not have a harbour
        @log.add(__callee__, 'Harbour is not useable'); false
      end
    end
    
    def is_double
      if defined? @dice && @dice_count >= 2
        return @dice[0]==@dice[1] ? true : false
      end
      return false
    end
    
    private
    def do_roll
      @dice = Array.new()
      @dice_count.times { @dice << 1 + rand(6) }
      @log.add(__callee__, "The dice were rolled : #{@dice}")
      @dice
    end
    
  end

  class BuildingResolver
  
    attr_accessor :roll_val
  
    def initialize(log, player, players)
      @log = log
      @p = player
      @players = players
    end
  
    # anti-clockwise, starting with the player whose turn it is
    def resolution_order
      return @resolution_order if defined? @resolution_order
      @resolution_order = @players.reverse
      @resolution_order.rotate!(@resolution_order.index(@p))
    end
    
    # returns a hash of 4 values, one for each colour.
    # each hash is an array of "slots"
    # a slot is an array of the format [card, card_count, player]
    def get_cards(roll_val = @roll_val)
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
  
    def process_cards(roll_val = @roll_val)
      slots = get_cards(roll_val)
      process_blue(slots[:blue])
      process_green(slots[:green])
      process_red(slots[:red])
      process_purple(slots[:purple])
    end
    
    def process_blue(blue_array)
      #curr_player = 0
      blue_array.each do |slot|
        income = slot[0].attribute[:base_income] * slot[1]
        @log.add(__callee__, "#{slot[2].name} has #{slot[1]} x #{slot[0].attribute[:name]} = #{income}")
        slot[2].money += income
      end
    end
    
    def process_green(green_array)
      green_array.each do |slot|
        income = slot[0].attribute[:base_income] * slot[1]
        @log.add(__callee__,"#{slot[2].name} has #{slot[1]} x #{slot[0].attribute[:name]} = #{income}")
        slot[2].money += income
      end
    end
    
    def process_red(red_array)
      red_array.each do |slot|
        income = slot[0].attribute[:base_income] * slot[1]
        income = @p.money if @p.money < income
        @log.add(__callee__,"#{slot[2].name} has #{slot[1]} x #{slot[0].attribute[:name]} = #{income} from #{@p.name}")
        slot[2].cash += income
        @p.cash += -income
      end
    end
    
    def process_purple(purple_array)
      #TODO once purple cards are added
    end
  
  end
  
  class Turn

    attr_accessor :stage, :player
    # each turn, the following steps happen / must be checked
    # Useful to prompt the front end regarding what is to be done next
    @@stages = [:roll,
                :consider_reroll,
                :consider_harbour,
                :activate_buildings,
                :consider_dole_money,
                :purchase_card,
                :check_for_win,
                :consider_airport,
                :end_turn]
  
    def initialize(game, player)
      @g = game
      @player = player
      @g.log.add(__callee__, "A new turn has been created (#{player.name})")
      #@p_abilities = @p.built_landmarks.reduce([]) { |arr, l| arr.concat(l.ability) }
      @purchased_card = nil
      @stage = @@stages[0]
      @BuildingResolver = BuildingResolver.new(game.log, player, game.players)
    end
    
    
    def roll_dice(dice_count)
      @dice ||= DiceRoll.new(dice_count, 
                              @player.has_ability(:reroll)? false : true,
                              @player.has_ability(:harbour)? false : true,
                              @g.log)
      @dice.roll
    end

    def sum_dice
      return @dice.sum_dice
    end

    # will return an error unless you roll the dice first
    def use_harbour
      @dice.use_harbour
    end
    
    def use_town_hall
      if @player.money==0 && @player.has_ability(:dole_money)
        @player.money+=1
        @g.log.add(__callee__, 'Town hall activated - 1 money given')
        true
      else
        @g.log.add(__callee__, 'Town hall is not useable')
        false
      end
    end
    
    def use_airport
      if @purchased_card.nil? && @player.has_ability(:no_buy_boost)
        @player.money+=10
        @g.log.add(__callee__, 'Airport activated - 10 money given')
        true
      else
        @g.log.add(__callee__, 'Airport is not useable')
        false
      end
    end 
    
    def process_cards(roll_val)
      @BuildingResolver.process_cards(roll_val)
    end
    
    def resolution_order; @BuildingResolver.resolution_order; end
    
    def get_cards(roll_val); @BuildingResolver.get_cards(roll_val); end
    
    def next_stage
      return false if @stage == @@stages.last
      @stage = @@stages[@@stages.index(@stage)+1]
    end
  end

end