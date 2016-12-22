#require_relative 'db_access'

module MachiKoro

MAX_PLAYER_LIMIT = 5
DEFAULT_MONEY = 3

  class Game
  
    attr_reader :player_list, :town, :stockpile

    def initialize
      @town = MachiKoro::Tableau.new
      @stockpile = MachiKoro::Tableau.new
      @databank = MachiKoro::Databank.new
      @player_list = Array.new()
      initialize_town
    end
    
    def add_player(name)
      players_so_far = @player_list.count
      return false if players_so_far >= MAX_PLAYER_LIMIT
      new_tableau = new_player_tableau
      
      @player_list << MachiKoro::Player.new(name, players_so_far+1, \
                                            new_player_tableau(), \
                                            new_player_landmarks(true), \
                                            new_player_landmarks(false))
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
      #TODO this won't work whilst there ar eno purple cards in the deck
      #while @town.distinct_count < 12
      #  card = @stockpile.random_card(1,99,true)
      #  move_card_from_stockpile_to_town(card)
      #end
    end
  
    private
    def move_card_from_stockpile_to_town(card)
      @stockpile.remove_card(card)
      @town.add_card(card)
    end
    
  end

end