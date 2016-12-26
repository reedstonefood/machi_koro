module MachiKoro

  class Player

    attr_reader :name, :turn_order, :tableau, :built_landmarks, :unbuilt_landmarks
    attr_accessor :money
  
    def initialize(name, turn_order, tableau, built_l, unbuilt_l)
      @name = name
      @turn_order = turn_order
      @tableau = tableau
      @money = DEFAULT_MONEY
      @built_landmarks = built_l
      @unbuilt_landmarks = unbuilt_l
    end
    
    def has_ability(needle)
      abilities = built_landmarks.reduce([]) { |arr, l| arr.concat(l.ability) }
      abilities.include?(needle)
    end

    def symbol_boosts()
    
    end
    
  end

end