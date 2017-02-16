require 'sqlite3'

# turns out that testing if a string is an integer is non-trivial
# the internet suggests this as a good option.
class String
  def is_integer?
    self.to_i.to_s == self
  end
end

module MachiKoro

  class DBAccess

    def initialize
      @db = SQLite3::Database.open "machi_koro.db"
      @db.results_as_hash = true
      @db.type_translation = true # the type of the data will be that of the DB
                                  # as opposed to always being String
    end

    def get_establishment(search_criteria)
      if search_criteria.to_s.is_integer?
        result = @db.execute( "SELECT * FROM establishments WHERE id = ?",
                                search_criteria)
      else #it's a string!
        result = @db.execute( "SELECT * FROM establishments
                                WHERE description = ?",
                                search_criteria)
      end
    
      # we will have an array of one hash. Due to UNIQUE constraints,
      # it is impossible to return more. So we can safely return that 1 hash.
      result.size==0 ? false : result[0]
    end
    
    def get_all_establishments
      @db.execute( "SELECT e.*, c.description AS colour
                      , s.description AS symbol
                      , ex.description AS expansion
                      , alt.description AS alternative_income_method
                      , re.description AS establishment_multiplier
                      , rs.description AS symbol_multiplier
                      , rl.description AS required_landmark
                    FROM establishments e
                    INNER JOIN colours c ON e.colour_id = c.id
                    INNER JOIN symbols s ON e.symbol_id = s.id
                    INNER JOIN expansions ex ON e.expansion_id = ex.id
                    LEFT JOIN alternative_income_methods alt
                      ON e.alternative_income_method_id = alt.id
                    LEFT JOIN establishments re ON e.activate_required_establishment_id = re.id
                    LEFT JOIN symbols rs ON e.activate_required_symbol_id = rs.id
                    LEFT JOIN landmarks rl ON e.activate_required_landmark_id = rl.id
                    ORDER BY from_roll ASC, to_roll ASC" )
    end
    
    def get_all_landmarks
      # this statement isn't ANSI-standard so may need changing on non SQLite DB's
      @db.execute( "SELECT l.*
                      , ex.description AS expansion
                      , GROUP_CONCAT(s.description) AS boosted_symbols
                    FROM landmarks l
                    INNER JOIN expansions ex ON l.expansion_id = ex.id
                    LEFT JOIN landmark_symbol_boosts lsb
                      ON lsb.landmark_id = l.id
                    LEFT JOIN symbols s ON s.id = lsb.symbol_id
                    GROUP BY l.id
                    ORDER BY l.cost DESC" )
    end
    
  end
end