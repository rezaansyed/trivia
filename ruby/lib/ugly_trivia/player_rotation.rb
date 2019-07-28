module UglyTrivia
  class PlayerRotation
    def initialize
      @players = []
    end

    def add(player)
      @players << player
    end

    def winner?
      @players.any? { |player| player.purse.total == 6 }
    end

    def number_of_players
      @players.length
    end

    def current_player
      @players.first
    end

    def move_to_next_player
      @players.rotate!
    end
  end
end
