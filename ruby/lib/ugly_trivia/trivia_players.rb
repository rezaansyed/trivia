class TriviaPlayers
  def initialize
    @players = []
    @current_index = 0
  end

  def current_player
    return if @players.empty?
    @players[@current_index]
  end

  def add(player)
    @players.push player
  end

  def next_player
    @current_index = (@current_index + 1) % @players.length
    current_player
  end

  def length
    @players.size
  end
end
