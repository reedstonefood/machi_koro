require 'highline'


module MachiKoro

  class CLI
    
    # actual turn action thingys!
    # use_airport, use_harbour and use_town_hall are defined in the Turn object
    #[:train_station,
    #            :roll,
    #            :consider_reroll,
    #            :consider_harbour,
    #            :activate_buildings,
    #            :consider_dole_money,
    #            :purchase_card,
    #            :check_for_win,
    #            :consider_airport,
    #            :end_turn]
    
    def roll(turn)
      dice_count = nil
      if turn.player.has_ability(:two_dice)
        @@cli.choose do |menu|
          menu.prompt = "Roll one dice or two? "
          menu.choice(:one) { dice_count = 1 } #dice_count = 1
          menu.choice(:two) { dice_count = 2 } #dice_count = 2
        end
      else
        dice_count = 1
      end
      loop do
        a = @@cli.ask "Press enter to roll > "
        break if !common_options(a)
      end
      dice = turn.roll_dice(dice_count)
      statement = "You rolled #{turn.sum_dice}"
      @@cli.say statement if dice_count == 1
      @@cli.say statement + "(#{dice[0]} + #{dice[1]})" if dice_count == 2
    end
    
    def consider_reroll(turn)
      @@cli.say "CONSIDER REROLL!!!"
      answer = nil
      if turn.player.has_ability(:reroll)
        loop do
          answer = @@cli.ask "Do you want to re-roll your roll of (#{turn.sum_dice})? "
          break if YES_NO_VALUES.include? answer
          common_options(answer)
        end
        if YES_VALUES.include? answer
          @@cli.say "OK, you can roll again."
          turn.stage = :roll
        else
          @@cli.say "OK, you are staying with your roll of #{turn.sum_dice}."
        end
      end
    end
    
    def consider_harbour(turn)
      answer = nil
      if turn.player.has_ability(:harbour) && turn.sum_dice >= 10
        loop do
          answer = @@cli.ask "Do you want to use your harbour to add 2 to your roll of (#{turn.sum_dice})? "
          break if YES_NO_VALUES.include? answer
          common_options(answer)
        end
        if YES_VALUES.include? answer
          turn.use_harbour
          @@cli.say "OK, your roll is now (#{turn.sum_dice})"
        end
      end
    end
    
    def activate_buildings(turn)
      @@cli.say "Starting to activate buildings." if @verbose == true
      turn.process_cards(turn.sum_dice)
      @@cli.say "Finished activating buildings." if @verbose == true
    end
    
    def consider_dole_money(turn)
      if turn.player.has_ability(:dole_money) && turn.player.money == 0
        if turn.use_town_hall==true
          @@cli.say "You have been given 1 coin due to the Town Hall"
        else
          @@cli.say "You are due 1 coin from the Town Hall, but the code failed."
        end
      else
        @@cli.say "You do not meet the criteria for dole money." if @verbose == true
      end
    end
    
    # chosen_array is an array of 3 elements
    # These are defined in the first line of the method
    
    def process_purchase_of_card(turn, chosen_data)
      @purchased_card = chosen_data[1] #TODO I don't think this should be in the CLI
      type_of_card, card, card_cost = chosen_data[0], chosen_data[1], chosen_data[2]
      turn.player.money = turn.player.money - card_cost
      if type_of_card == :landmark
        turn.player.unbuilt_landmarks.delete(card)
        turn.player.built_landmarks.push(card)
      elsif type_of_card == :establishment
        @mk.town.remove_card(card)
        turn.player.tableau.add_card(card)
        while @mk.town.distinct_count < TOWN_SIZE
          new_card = card.attribute[:to_roll] <= 6 ? @mk.stockpile.random_card(1, 6) : @mk.stockpile.random_card(7, 14)
          @mk.town.add_card(new_card)
          @mk.stockpile.remove_card(new_card)
          @@cli.say "Town replenished by adding <%= color('#{new_card.attribute[:name]}', BOLD) %>. "
        end
      else false #method has recieved some weird unexpected data
      end
    end
    
    # We want to offer the user a choice of something from 4 sets. 
    # 1) The cards available in the town.
    # 2) Unbuilt landmarks.
    # 3) Databank menu (in which case, repeat, once databank is dealt with)
    # 4) Purchase nothing.
    
    # 1) @mk.town is a Tableau
    # 2) turn.player.unbuild_landmarks is a simple Array
    # 3 and 4 are one-off menu options
    
    # The idea is, to make a hash, where key is the text displayed, and value is the ID of the card (?)
    # This is tricky due to the need to combine 1 and 2.
    # So how about, key => (establishment/landmark, ID)
    
    def purchase_card(turn)
      own_money = turn.player.money
      keep_repeating = true
      while keep_repeating == true do
        keep_repeating = false 
        @@cli.say "Now it is time to purchase a card; you have <%= color('#{own_money}', BOLD) %> money."
        # Create a hash for the cards in the town
        town_cards = Hash[ @mk.town.deck.map {|e| ["#{e[1]} x #{e[0].attribute[:name]} (#{e[0].attribute[:cost]})", [:establishment, e[0], e[0].attribute[:cost]]]} ]
        card_name_list = town_cards.sort_by { |key, val| val[1].attribute[:from_roll] }.to_h
        # add the landmarks
        card_name_list.merge!(Hash[ turn.player.unbuilt_landmarks.map {|l| ["#{l.name} (#{l.cost})", [:landmark, l, l.cost]]} ])
        @@cli.choose do |menu|
          menu.prompt = "Which card to do you want to buy? "
          menu.choices(*card_name_list.keys) do |chosen|
            @@cli.say "You have chosen <%= color('#{chosen}', BOLD) %>. "
            if own_money < card_name_list[chosen][2]
              @@cli.say "You can't afford that! It costs #{card_name_list[chosen][2]} but you only have #{own_money}"
              keep_repeating = true
            else
              process_purchase_of_card(turn, card_name_list[chosen])
            end
          end
          menu.choice(:none, {:text => "NOTHING TO ME, AH VIENNA"}) { @@cli.say "OK, you have chosen to not purchase any card."}
          menu.choice(:databank) { databank_menu; keep_repeating = true}
        end
      end
    end
    
    def check_for_win(turn)
      if turn.player.unbuilt_landmarks.empty?
        @@cli.say "YOU ARE THE WINNER!!!"
        @exit_flag = true
      end
    end
    
    def consider_airport(turn)
      if turn.player.has_ability(:no_buy_boost) && @purchased_card.nil?
        if turn.use_airport==true
          @@cli.say "You have been given 10 coins due to not buying anything."
        else
          @@cli.say "You are due 10 coins due to not buying anything, but the code failed."
        end
      end
    end
    
    def end_turn(turn)
      #todo have another turn???
      @@cli.say "Your turn is over!"
      @purchased_card = nil
    end
    
    # end of actual turn action thingys!
    
  
  end #class

end #module