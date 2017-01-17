require 'highline'


module MachiKoro

  YES_VALUES = ['Y','y','yes','Yes','YES']
  NO_VALUES = ['N','n','NO','no','No']
  YES_NO_VALUES = YES_VALUES + NO_VALUES

  class CLI
    @@cli = HighLine.new
  
    def initialize(mode = nil)
      @exit_flag = false
      if mode == 'v'
        @mk = MachiKoro::Game.new("v")
      else
        @mk = MachiKoro::Game.new()
      end
      welcome
      choose_players
      main
    end
    
    def welcome
      @@cli.say "**************************************************"
      @@cli.say "* WELCOME TO MACHI KORO - A Ruby implementation **"
      @@cli.say "**************************************************"
    end
    
    def end_game
      @@cli.say "Goodbye!"
    end
    
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
      if turn.player.has_ability(:two_dice)
        @@cli.choose do |menu|
          menu.prompt = "Roll one dice or two? "
          menu.choice(:one) { dice_count = 1 }
          menu.choice(:two) { dice_count = 2 }
        end
      else dice_count = 1; end
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
      if turn.player.has_ability(:reroll)
        loop do
          a = @@cli.ask "Do you want to re-roll your roll of (#{turn.sum_dice})? "
          break if YES_NO_VALUES.include? a
          common_options(a)
        end
        if YES_VALUES.include? a
          #TODO this will fail - need to know # of dice. Refactor to keep it DRY
          new_dice = turn.roll_dice
          statement = "OK, your new roll is #{turn.sum_dice}"
          @@cli.say statement if dice_count == 1
          @@cli.say statement + "(#{dice[0]} + #{dice[1]})" if dice_count == 2
        end
      end
    end
    
    def consider_harbour(turn)
      if turn.player.has_ability(:harbour) && turn.sum_dice >= 10
        loop do
          a = @@cli.ask "Do you want to use your harbour to add 2 to your roll of (#{turn.sum_dice})? "
          break if YES_NO_VALUES.include? a
          common_options(a)
        end
        if YES_VALUES.include? a
          turn.use_harbour
          @@cli.say "OK, your roll is now (#{turn.sum_dice})"
        end
      end
    end
    
    def activate_buildings(turn)
      @@cli.say "ACTIVATE BUILDINGS!!!"
    end
    
    def consider_dole_money(turn)
      @@cli.say "Consider dole money!"
    end
    
    def purchase_card(turn)
      @@cli.say "PURCHASE CARD!!! "
      # maybe don't use menu system, and just use tableau console_output
      card_name_list = {}
      @@cli.choose do |menu|
        menu.prompt = "Which card to do you want to buy? "
        menu.choices(*card_name_list) do |chosen|
          @@cli.say "You have chosen <%= color('#{chosen}', BOLD) %>. "
          @mk.players.find { |p| p.name==chosen }.tableau.console_output
        end
        menu.choice(:none) { @@cli.say "OK, leaving tableau menu"}
      end
    end
    
    def check_for_win(turn)
      #if @mk.
    end
    
    def consider_airport(turn)
      if turn.player.has_ability(:no_buy_boost) && turn.purchased_card = nil
        @@cli.say "Looks like your airport has been activated. Shame activating this hasn't been coded yet."
        # Call turn.use_airport, which returns true/false
      end
    end
    
    def end_turn(turn)
      @@cli.say "Your turn is over!"
    end
    
    # end of actual turn action thingys!
    
    def tableau_menu
      player_name_list = @mk.players.collect { |p| p.name }
      @@cli.choose do |menu|
        menu.prompt = "Whose situation do you want information on? "
        menu.choices(*player_name_list) do |chosen|
          @@cli.say "You have chosen <%= color('#{chosen}', BOLD) %>. "
          @mk.players.find { |p| p.name==chosen }.tableau.console_output
        end
        menu.choice(:none) { @@cli.say "OK, leaving tableau menu"}
      end
    end
    
    def landmark_menu(mode)
      landmark_name_list = @mk.databank.landmarks.collect { |l| l.name }
      @@cli.choose do |menu|
        menu.prompt = "Choose a landmark... "
        menu.choices(*landmark_name_list) do |chosen|
          @@cli.say "You have chosen <%= color('#{chosen}', BOLD) %>."
          @mk.databank.landmarks.find { |p| p.name==chosen }.console_output
        end
        menu.choice(:none) { @@cli.say "OK, leaving landmark menu"}
      end
    end
    
    def establishment_menu(mode)
      establishment_name_list = @mk.databank.establishments.collect { |l| l.attribute[:name] }
      @@cli.choose do |menu|
        menu.prompt = "Choose a landmark... "
        menu.choices(*establishment_name_list) do |chosen|
          @@cli.say "You have chosen <%= color('#{chosen}', BOLD) %>."
          @mk.databank.establishments.find { |p| p.attribute[:name]==chosen }.console_output
        end
        menu.choice(:none) { @@cli.say "OK, leaving establishment menu"}
      end
    end
    
    def databank_menu
      @@cli.say "********** DATABANK MENU **********"
      @@cli.choose do |menu|
        menu.prompt = "What do you want more information on? "
        menu.choice(:landmarks) { landmark_menu(:info) }
        menu.choice(:establishments) { establishment_menu(:info) }
        menu.choice(:cancel) { @@cli.say "OK, leaving databank menu" }
      end
    end
    
    def summary
      @@cli.say "Here is where you will be able to see a summary of the game as it stands"
    end
    
    def do_exit
      @exit_flag = true
    end
    
    def common_options(input) # y and n cannot be in here! It will break other stuff
      case input[0] # we only care about the first letter
      when 't'
        tableau_menu; true
      when 'd'
        databank_menu; true
      when 'h'
        help; true
      when 'i', 's'
        summary; true
      when 'x'
        do_exit; true
      else
        false
      end
    end
    
    def choose_players
      count = 1 
      @@cli.say "Name all the players. Input 'done' when you are done."
      loop do
        pname = @@cli.ask("Enter name of player #{count} > ") do |q| 
          q.validate = lambda { |a| a.length >= 1 && a.length <= 30 }
          #q.ask_on_error_msg = "Name must be between 1 and 30 characters"
        end
        if pname.downcase == 'done'
          break if count >=3
          @@cli.say "You need to input at least 2 players!"
        elsif @mk.add_player(pname)== true
          count += 1
          @@cli.say "*** #{pname} successfully added"
        else
          @@cli.say "*** Sorry, there was a problem adding player #{pname}"
        end
        break if count >= 6
      end
      @@cli.say "Succesfully added #{count-1} players. Game is ready to start."
    end
    
    def help
      @@cli.say "************************ HELP! ************************"
      @@cli.say "<%= color('(t)ableau', BOLD) %> = View someone's (or the town's) tableau"
      @@cli.say "<%= color('(d)atabank', BOLD) %> = Details of a card"
      @@cli.say "<%= color('(s)ummary', BOLD) %> = player's cash / landmarks"
      @@cli.say "<%= color('(h)elp', BOLD) %> = This help page"
      @@cli.say "<%= color('e(x)it', BOLD) %> = Exit the program"
    end
    
    def do_turn(turn)
      loop do
        self.public_send(turn.stage,turn)
        break if !turn.next_stage
        #@exit_flag==true
      end
    end
    
    def main
      @turn_no = 1
      catch :exit do
        loop do
          @mk.players.each do |player|
            @@cli.say "*** It is now the turn of #{player.name}. Turn ##{@turn_no}"
            turn = MachiKoro::Turn.new(@mk, player)
            do_turn(turn)
            throw :exit if @exit_flag==true
          end
          @turn_no += 1
        end
      end
      end_game
    end
  
  end #class

end #module