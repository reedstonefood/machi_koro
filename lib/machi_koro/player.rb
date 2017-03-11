module MachiKoro

  # codebeat:disable[TOO_MANY_IVARS]
  class Player

    attr_reader :name, :turn_order, :tableau, :built_landmarks, :unbuilt_landmarks
    attr_accessor :money
  
    # codebeat:disable[ARITY]
    def initialize(name, turn_order, tableau, built_l, unbuilt_l)
      @name = name
      @turn_order = turn_order
      @tableau = tableau
      @money = DEFAULT_MONEY
      @built_landmarks = built_l
      @unbuilt_landmarks = unbuilt_l
    end
    # codebeat:enable[ARITY]
    
    def has_ability(needle)
      abilities = built_landmarks.reduce([]) { |arr, l| arr.concat(l.ability) }
      abilities.include?(needle)
    end

    def has_built_landmark?(find_landmark)
      !@built_landmarks.find { |l| l.name == find_landmark }.nil?
    end
    
  end
  # codebeat:enable[TOO_MANY_IVARS]

end