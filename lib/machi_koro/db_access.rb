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
      @db.execute( "SELECT * FROM establishments" )
    end
    
  end
end