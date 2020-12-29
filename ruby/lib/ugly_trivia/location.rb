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
