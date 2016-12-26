require 'highline'

module MachiKoro

  class CLI
  
    def initialize(mode = nil)
      @cli = HighLine.new
      if mode == 'v'
        @mk = MachiKoro::Game.new("v")
      else
        @mk = MachiKoro::Game.new()
      end
      welcome
      choose_players
      main
    end
    
    def welcome()
      @cli.say "**************************************************"
      @cli.say "* WELCOME TO MACHI KORO - A Ruby implementation **"
      @cli.say "**************************************************"
    end
    
    def choose_players()
      count = 1 
      @cli.say "Name all the players. Input 'x' when you are done."
      loop do
        pname = @cli.ask("Enter name of player #{count} >")
        break if pname == 'x'
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
    
    def help()
      @cli.say "Help will be here, but hasn't been written yet. Sorry."
    end
    
    def main()
      turn_no = 1
      loop do
        answer = @cli.ask("T{turn_no} >")
        help if answer == 'x'
        break if answer == 'end'
        turn_no += 1
      end
    end
  end

end