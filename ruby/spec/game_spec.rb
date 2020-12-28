require 'spec_helper'
require 'ugly_trivia/game'
require 'ugly_trivia/accumulating_output'

describe "game" do
  output = AccumulatingOutput.new

  it "is not playable if less than 2 players" do
    game = UglyTrivia::Game.new(output)

    game.add('Player 1')

    expect(game.is_playable?).to be_falsey
  end

  it "is playable if 2 or more players" do
    game = UglyTrivia::Game.new(output)

    game.add('Player 1')
    game.add('Player 2')

    expect(game.is_playable?).to be_truthy
  end

  it "add 7 players to game" do
    game = UglyTrivia::Game.new(output)

    game.add('Player 1')
    game.add('Player 2')
    game.add('Player 3')
    game.add('Player 4')
    game.add('Player 5')
    game.add('Player 6')
    game.add('Player 7')

    expect(game.purses.length).to eql(7)
  end
end
