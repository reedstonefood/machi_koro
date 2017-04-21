module MachiKoro

  class DiceRoll
  
    attr_reader :dice_count, :harbour_available, :reroll_available
  
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
      input.inject(0, :+) # did use a ||= but re-rolls messed it up
    end
    
    def use_harbour
      if self.sum_dice >=10 && @harbour_available == true
        #@sum_dice += 2
        @dice[2] = 2 # pretend it has a third dice that is a 2
        @harbour_available = false
        @log.add(__callee__, 'Harbour has been activated')
        true
      else # harbour has been used - or player does not have a harbour
        @log.add(__callee__, 'Harbour is not useable'); false
      end
    end
    
    def is_double?
      if defined? @dice && @dice_count >= 2
        return @dice[0]==@dice[1] ? true : false
      end
      false
    end
    
    # Used for testing
    def fix_dice(desired_dice_array)
      @dice = desired_dice_array
    end
    
    private
    def do_roll
      @dice = Array.new()
      @dice_count.times { @dice << 1 + rand(6) }
      @log.add(__callee__, "The dice were rolled : #{@dice}")
      @dice
    end
    
  end

  # codebeat:disable[TOO_MANY_IVARS]
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
    
    # Disabling ABC checks - each of these methods seems self-contained & well defined
    # It would feel artificial to cut them up anymore
    # codebeat:disable[ABC]
    # Also disable excessive nesting for process_blue. There are really only 3 levels. The 4th is seperate for clarity.
    # codebeat:disable[BLOCK_NESTING]
    def process_blue(blue_array)
      #curr_player = 0
      blue_array.each do |slot|
        income = slot[0].attribute[:base_income] * slot[1]
        income = tuna_boats if slot[0].attribute[:alternative_income_method] == :"roll 2d6"
        if !slot[0].attribute[:required_landmark].nil?
          income = 0 if !slot[2].has_built_landmark?(slot[0].attribute[:required_landmark])
        end
        @log.add(__callee__, "#{slot[2].name} has #{slot[1]} x #{slot[0].attribute[:name]} = #{income}")
        slot[2].money += income
      end
    end
    # codebeat:enable[BLOCK_NESTING]
    
    def process_green(green_array)
      green_array.each do |slot|
        #TODO make this more generic than the current shopping mall
        bonus = slot[2].has_ability(:symbol_boost) && slot[0].attribute[:symbol] == :bread ? 1 : 0 # this models the shopping mall, but doesn't model all the DB can hold
        income = (slot[0].attribute[:base_income] + bonus) * slot[1]
        if !slot[0].attribute[:establishment_multiplier].nil?
          income = income * @p.tableau.establishment_count(slot[0].attribute[:establishment_multiplier])
        end
        if !slot[0].attribute[:symbol_multiplier].nil?
          income = income * @p.tableau.symbol_count(slot[0].attribute[:symbol_multiplier])
        end
        @log.add(__callee__,"#{slot[2].name} has (#{slot[1]} + #{bonus}) x #{slot[0].attribute[:name]} x possibly something else = #{income}")
        slot[2].money += income
      end
    end
    
    def process_red(red_array)
      red_array.each do |slot|
        bonus = slot[2].has_ability(:symbol_boost) ? 1 : 0 # TODO this models the shopping mall, but doesn't model all the DB can hold
        income = (slot[0].attribute[:base_income] + bonus) * slot[1]  # Total due according to cards
        if !slot[0].attribute[:required_landmark].nil?
          income = 0 if !slot[2].has_built_landmark?(slot[0].attribute[:required_landmark])
        end
        income = @p.money if @p.money < income              # The player can't lose more money than they have
        @log.add(__callee__,"#{slot[2].name} has (#{slot[1]} + #{bonus}) x #{slot[0].attribute[:name]} = #{income} from #{@p.name}")
        slot[2].money += income
        @p.money += -income
      end
    end
    # codebeat:enable[ABC]
    
    def process_purple(purple_array)
      #TODO once purple cards are added
    end
    
    # Yay, tuna boats are awesome
    def tuna_boats()
      @tuna_haul ||= (1 + rand(6)) + (1 + rand(6))
      puts "TUNA BOAT POWER!!!"
      @log.add(__callee__,"Looks like Tuna Boats! The roll is #{tuna_haul}")
      return tuna_haul
    end
  
  end
  # codebeat:enable[TOO_MANY_IVARS]
  
  # codebeat:disable[TOO_MANY_IVARS]
  class Turn

    attr_accessor :stage, :player, :dice
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
                              @player.has_ability(:reroll)? true : false,
                              @player.has_ability(:harbour)? true : false,
                              @g.log)
      @dice.roll
    end

    def sum_dice
      return @dice.sum_dice
    end
    
    def rolled_double?
      @dice.is_double?
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
  # codebeat:enable[TOO_MANY_IVARS]
end