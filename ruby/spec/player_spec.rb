require 'spec_helper'
require 'ugly_trivia/game'
require 'ugly_trivia/player'
require 'ugly_trivia/accumulating_output'

describe "player" do
  it "creates new player with name" do
    player = Player.new(name: 'Player 1')

    expect(player.name).to eql('Player 1')
  end
end
