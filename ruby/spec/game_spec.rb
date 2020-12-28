require 'spec_helper'
require 'ugly_trivia/game'

describe "game" do
  it "adds new player to game" do
    game = UglyTrivia::Game.new

    game.add('Player 1')

    expect(game.players).to include('Player 1')
  end

  it "is not playable if less than 2 players" do
    game = UglyTrivia::Game.new

    game.add('Player 1')

    expect(game.is_playable?).to be_falsey
  end

  it "is playable if 2 or more players" do
    game = UglyTrivia::Game.new

    game.add('Player 1')
    game.add('Player 2')

    expect(game.is_playable?).to be_truthy
  end
end
