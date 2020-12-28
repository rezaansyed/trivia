class Player
  attr_reader :name, :place
  attr_accessor :purse

  def initialize(name:)
    @name = name
    @purse = 0
    @place = 0
    @in_penalty_box = false
  end

  def roll(roll_number)
    @place = (@place + roll_number) % 12
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
end
