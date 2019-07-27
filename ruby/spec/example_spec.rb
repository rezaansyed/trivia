require 'spec_helper'
require 'ugly_trivia/game'

describe "overall game" do
  it "play with 1 player in box alot bit of a game" do
    output = OutputCollector.new

    game = UglyTrivia::Game.new(output)

    game.add('alex')
    expect(output.consume_lines).to eq(["alex was added", "They are player number 1"])
    game.add('chunky')
    expect(output.consume_lines).to eq(["chunky was added", "They are player number 2"])

    game.roll(1)
    expect(output.consume_lines).to eq([
      "alex is the current player",
      "They have rolled a 1",
      "alex's new location is 1",
      "The category is Science",
      "Science Question 0",
    ])
    expect(game.wrong_answer).to eq(true)
    expect(output.consume_lines).to eq([
      "Question was incorrectly answered",
      "alex was sent to the penalty box",
    ])

    game.roll(2)
    expect(output.consume_lines).to eq([
      "chunky is the current player",
      "They have rolled a 2",
      "chunky's new location is 2",
      "The category is Sports",
      "Sports Question 0",
    ])
    expect(game.was_correctly_answered).to eq(true)
    expect(output.consume_lines).to eq([
      "Answer was corrent!!!!",
      "chunky now has 1 Gold Coins.",
    ])

    game.roll(1)
    expect(output.consume_lines).to eq([
      "alex is the current player",
      "They have rolled a 1",
      "alex is getting out of the penalty box",
      "alex's new location is 2",
      "The category is Sports",
      "Sports Question 1",
    ])
    expect(game.was_correctly_answered).to eq(true)
    expect(output.consume_lines).to eq([
      "Answer was correct!!!!",
      "alex now has 1 Gold Coins.",
    ])

    game.roll(2)
    expect(output.consume_lines).to eq([
      "chunky is the current player",
      "They have rolled a 2",
      "chunky's new location is 4",
      "The category is Pop",
      "Pop Question 0",
    ])
    expect(game.was_correctly_answered).to eq(true)
    expect(output.consume_lines).to eq([
      "Answer was corrent!!!!",
      "chunky now has 2 Gold Coins.",
    ])

    game.roll(1)
    expect(output.consume_lines).to eq([
      "alex is the current player",
      "They have rolled a 1",
      "alex is getting out of the penalty box",
      "alex's new location is 3",
      "The category is Rock",
      "Rock Question 0",
    ])
    expect(game.was_correctly_answered).to eq(true)
    expect(output.consume_lines).to eq([
      "Answer was correct!!!!",
      "alex now has 2 Gold Coins.",
    ])

    game.roll(2)
    expect(output.consume_lines).to eq([
      "chunky is the current player",
      "They have rolled a 2",
      "chunky's new location is 6",
      "The category is Sports",
      "Sports Question 2",
    ])
    expect(game.was_correctly_answered).to eq(true)
    expect(output.consume_lines).to eq([
      "Answer was corrent!!!!",
      "chunky now has 3 Gold Coins.",
    ])

    game.roll(1)
    expect(output.consume_lines).to eq([
      "alex is the current player",
      "They have rolled a 1",
      "alex is getting out of the penalty box",
      "alex's new location is 4",
      "The category is Pop",
      "Pop Question 1",
    ])
    expect(game.was_correctly_answered).to eq(true)
    expect(output.consume_lines).to eq([
      "Answer was correct!!!!",
      "alex now has 3 Gold Coins.",
    ])

    game.roll(2)
    expect(output.consume_lines).to eq([
      "chunky is the current player",
      "They have rolled a 2",
      "chunky's new location is 8",
      "The category is Pop",
      "Pop Question 2",
    ])
    expect(game.was_correctly_answered).to eq(true)
    expect(output.consume_lines).to eq([
      "Answer was corrent!!!!",
      "chunky now has 4 Gold Coins.",
    ])

    game.roll(1)
    expect(output.consume_lines).to eq([
      "alex is the current player",
      "They have rolled a 1",
      "alex is getting out of the penalty box",
      "alex's new location is 5",
      "The category is Science",
      "Science Question 1",
    ])
    expect(game.was_correctly_answered).to eq(true)
    expect(output.consume_lines).to eq([
      "Answer was correct!!!!",
      "alex now has 4 Gold Coins.",
    ])

    game.roll(2)
    expect(output.consume_lines).to eq([
      "chunky is the current player",
      "They have rolled a 2",
      "chunky's new location is 10",
      "The category is Sports",
      "Sports Question 3",
    ])
    expect(game.was_correctly_answered).to eq(true)
    expect(output.consume_lines).to eq([
      "Answer was corrent!!!!",
      "chunky now has 5 Gold Coins.",
    ])

    game.roll(1)
    expect(output.consume_lines).to eq([
      "alex is the current player",
      "They have rolled a 1",
      "alex is getting out of the penalty box",
      "alex's new location is 6",
      "The category is Sports",
      "Sports Question 4",
    ])
    expect(game.was_correctly_answered).to eq(true)
    expect(output.consume_lines).to eq([
      "Answer was correct!!!!",
      "alex now has 5 Gold Coins.",
    ])

    game.roll(2)
    expect(output.consume_lines).to eq([
      "chunky is the current player",
      "They have rolled a 2",
      "chunky's new location is 0",
      "The category is Pop",
      "Pop Question 3",
    ])
    expect(game.was_correctly_answered).to eq(false)
    expect(output.consume_lines).to eq([
      "Answer was corrent!!!!",
      "chunky now has 6 Gold Coins.",
    ])
  end

  class OutputCollector
    attr_reader :output

    def initialize
      @output = []
      @unconsumed = []
    end

    def write(line)
      @output << line
      @unconsumed << line
      puts line
    end

    def last(number = 1)
      @output.last(number)
    end

    def consume_lines
      result = @unconsumed.dup
      @unconsumed = []
      result
    end
  end
end
