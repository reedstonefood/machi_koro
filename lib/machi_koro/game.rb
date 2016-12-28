#require_relative 'db_access'
require 'date'

module MachiKoro

MAX_PLAYER_LIMIT = 5
DEFAULT_MONEY = 3

  class Game
  
    attr_reader :players, :town, :stockpile, :log

    def initialize(mode = nil)
      @log = MachiKoro::Log.new
      @log.add(__callee__, "A new Game object is being created")
      @town = MachiKoro::Tableau.new
      @stockpile = MachiKoro::Tableau.new
      @databank = MachiKoro::Databank.new
      @players = Array.new()
      initialize_town
    end
    
    def validate_player_name(check)
      if check.length < 1 || check.length > 30
        @log.add(__callee__, "Name length < 1 or > 30 (#{check})")
        return false
      elsif !@players.find { |p| p.name == check}.nil?
        @log.add(__callee__, "Name already exists (#{check})")
        return false
      end
      true
    end
    
    def add_player(name)
      players_so_far = @players.count
      return false if validate_player_name(name)==false
      if players_so_far >= MAX_PLAYER_LIMIT
        @log.add(__callee__, "Too many players")
        return false 
      end
      new_tableau = new_player_tableau
      @log.add(__callee__, "Creating & setting up player #{name}")
      @players << MachiKoro::Player.new(name, players_so_far+1, \
                                            new_player_tableau(), \
                                            new_player_landmarks(true), \
                                            new_player_landmarks(false))
      @log.add(__callee__, "Added player #{name}")
      return true
    end
    
    def new_player_tableau()
      output = MachiKoro::Tableau.new
      @databank.establishments.each do |e| #I'm sure there's a better way of doing this...
        output.add_card(e) if e.attribute[:name]=="Wheat Field"
        output.add_card(e) if e.attribute[:name]=="Bakery"
      end
      output
    end
    
    def new_player_landmarks(built_status)
      @databank.landmarks.find_all { |l| l.pre_built == built_status }
    end
    
    def console_setup
    
    end
    
    def initialize_town
      @log.add(__callee__, "Starting to initialize town")
      @databank.establishments.each do |e|
        6.times { @stockpile.add_card(e) }
      end
      while @town.distinct_count < 5
        card = @stockpile.random_card(1,6,false)
        move_card_from_stockpile_to_town(card)
      end
      while @town.distinct_count < 10
        card = @stockpile.random_card(7,14,false)
        move_card_from_stockpile_to_town(card)
      end
      #TODO this won't work whilst there are no purple cards in the deck
      #while @town.distinct_count < 12
      #  card = @stockpile.random_card(1,99,true)
      #  move_card_from_stockpile_to_town(card)
      #end
      @log.add(__callee__, "Finished initializing town")
    end
  
    private
    def move_card_from_stockpile_to_town(card)
      @stockpile.remove_card(card)
      @town.add_card(card)
    end
    
  end
  
  class Log
  
    def initialize
      @data = Array.new()
    end
  
    def add(callee, msg)
      current_datetime = DateTime.now.strftime "%d/%m/%Y %H:%M:%S:%L"
      @data << [current_datetime, callee, msg]
    end
  
  end

end