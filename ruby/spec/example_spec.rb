require 'spec_helper'
require 'ugly_trivia/game'

describe "overall game" do
  it "play a bit of a game" do

    game = UglyTrivia::Game.new

    game.add('alex')
    game.add('chunky')

    game.roll(1)
    expect(game.was_correctly_answered).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(true)

    game.roll(1)
    expect(game.was_correctly_answered).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(true)

    game.roll(1)
    expect(game.was_correctly_answered).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(true)

    game.roll(1)
    expect(game.was_correctly_answered).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(true)

    game.roll(1)
    expect(game.was_correctly_answered).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(true)

    game.roll(1)
    expect(game.was_correctly_answered).to eq(false)
  end

  it "play with 1 player in box alot bit of a game" do

    game = UglyTrivia::Game.new

    game.add('alex')
    game.add('chunky')

    game.roll(1)
    expect(game.wrong_answer).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(true)

    game.roll(1)
    expect(game.was_correctly_answered).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(true)

    game.roll(1)
    expect(game.was_correctly_answered).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(true)

    game.roll(1)
    expect(game.was_correctly_answered).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(true)

    game.roll(1)
    expect(game.was_correctly_answered).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(true)

    game.roll(1)
    expect(game.was_correctly_answered).to eq(true)
    game.roll(2)
    expect(game.was_correctly_answered).to eq(false)
  end
end
