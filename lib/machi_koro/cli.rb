require 'highline'

module MachiKoro

  class CLI
  
    def initialize(mode = nil)
      @cli = HighLine.new
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
      @cli.say "**************************************************"
      @cli.say "* WELCOME TO MACHI KORO - A Ruby implementation **"
      @cli.say "**************************************************"
    end
    
    def end_game
      @cli.say "Goodbye!"
    end
    
    
    def tableau_menu
      @cli.ask "Whose situation do you want information on? "
      @cli.say "That's nice, but it hasn't been implemented yet."
    end
    
    def databank_menu
      @cli.ask "What do you want to look up? "
      @cli.say "That's nice, but it hasn't been implemented yet."
    end
    
    def summary
      @cli.say "Here is where you will be able to see a summary of the game as it stands"
    end
    
    def do_exit
      @exit_flag = true
    end
    
    def common_options(input)
      i=input[0] # we only care about the first letter
      if i=='t'
        tableau_menu; true
      elsif i=='d'
        databank_menu; true
      elsif i=='h'
        help; true
      elsif i=='i' || i=='s'
        summary; true
      elsif i=='e'
        do_exit; true
      else
        false
      end
    end
    
    def choose_players
      count = 1 
      @cli.say "Name all the players. Input 'done' when you are done."
      loop do
        pname = @cli.ask("Enter name of player #{count} > ") do |q| 
          q.validate = lambda { |a| a.length >= 1 && a.length <= 30 }
          #q.ask_on_error_msg = "Name must be between 1 and 30 characters"
        end
        break if pname.downcase == 'done'
        if @mk.add_player(pname)== true
          count += 1
          @cli.say "*** #{pname} successfully added"
        else
          @cli.say "*** Sorry, there was a problem adding player #{pname}"
        end
        break if count >= 6
      end
      @cli.say "Succesfully added #{count-1} players. Game is ready to start."
    end
    
    def help
      @cli.say "************************ HELP! ************************"
      @cli.say "Help will be here, but hasn't been written yet. Sorry."
      #@cli.say "<%= color('(t)ableau', BOLD %> = View someone's (or the town's) tableau"
      #@cli.say "<%= color('(d)atabank', BOLD %> = Details of a card"
      #@cli.say "<%= color('(s)ummary', BOLD %> = player's cash / landmarks"
      #@cli.say "<%= color('(h)elp', BOLD %> = This help page"
      #@cli.say "<%= color('(e)xit', BOLD %> = Exit the program/n"
    end
    
    def do_turn(turn)
      loop do
        answer = @cli.ask "Type something > "
        if common_options(answer)==true
        elsif answer == 'q'
          @cli.say "Your turn is over!"
          break
        else
          @cli.say "Sorry, I did not understand that."
        end
        break if @exit_flag==true
      end
    end
    
    def main
      @turn_no = 1
      catch :exit do
        loop do
          @mk.players.each do |player|
            @cli.say "*** It is now the turn of #{player.name}. Turn ##{@turn_no}"
            turn = MachiKoro::Turn.new(@mk, player)
            do_turn(turn)
            throw :exit if @exit_flag==true
          end
          @turn_no += 1
        end
      end
      end_game
    end
  end

end