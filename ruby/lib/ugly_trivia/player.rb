class Location
  def initialize
    @location = 0
  end

  def move(roll)
    @location = (@location + roll) % 12
  end

  def category
    return 'Pop' if @location % 4 == 0
    return 'Science' if @location % 4 == 1
    return 'Sports' if @location % 4 == 2
    return 'Rock'
  end

  def to_s
    @location.to_s
  end
end

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

  def current_category
    @location.category
  end
end
