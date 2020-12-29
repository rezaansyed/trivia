require_relative './location'

class Player
  attr_reader :name, :location
  attr_accessor :purse

  def initialize(name:)
    @name = name
    @purse = 0
    @location = Location.new
    @in_penalty_box = false
  end

  def in_penalty_box?
    @in_penalty_box
  end

  def place_in_penalty_box
    @in_penalty_box = true
  end

  def remove_from_penalty_box
    @in_penalty_box = false
  end

  def in_penalty_box_with_even_roll(roll)
    current_player.in_penalty_box? && roll % 2 == 0
  end
end
