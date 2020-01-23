class AccumulatingOutput
  attr_reader :lines

  def initialize
    @lines = []
  end

  def write(line)
    @lines << line
  end
end
