module UglyTrivia
  class Player
    attr_reader :purse
    attr_reader :board_location

    def initialize(name, board_location, purse)
      @name = name
      @purse = purse
      @board_location = board_location
    end

    def to_s
      @name
    end

    def ==(other)
      other.class == self.class &&
        other.to_s == to_s
    end
  end
end
