# frozen_string_literal: true

require 'spec_helper'
require 'ugly_trivia/game'
require 'ugly_trivia/accumulating_output'

describe 'Previous behaviour' do
  it "should run the game the same as before" do
    REFERENCE_OUTPUT.each do |reference_output|
      output = run_game(reference_output[:random_seed])
      reference_output[:output_lines].zip(output).each_with_index do |(expected, actual), idx|
        expect(expected).to eq(actual), -> { "Expected '#{expected}' but got '#{actual}' on index #{idx}" }
      end
    end
  end

  private

  def run_game(seed)
    rng = Random.new(seed)
    not_a_winner = false
    output = AccumulatingOutput.new

    game = UglyTrivia::Game.new(output)

    game.add 'Chet'
    game.add 'Pat'
    game.add 'Sue'

    begin
      game.roll(rng.rand(5) + 1)

      if rng.rand(9) == 7
        not_a_winner = game.wrong_answer
      else
        not_a_winner = game.was_correctly_answered
      end
    end while not_a_winner

    output.lines
  end

  REFERENCE_OUTPUT = [
    {
      random_seed: 123,
      output_lines: [
        'Chet was added',
        'They are player number 1',
        'Pat was added',
        'They are player number 2',
        'Sue was added',
        'They are player number 3',
        'Chet is the current player',
        'They have rolled a 3',
        'Chet\'s new location is 3',
        'The category is Rock',
        'Rock Question 0',
        'Answer was corrent!!!!',
        'Chet now has 1 Gold Coins.',
        'Pat is the current player',
        'They have rolled a 2',
        'Pat\'s new location is 2',
        'The category is Sports',
        'Sports Question 0',
        'Answer was corrent!!!!',
        'Pat now has 1 Gold Coins.',
        'Sue is the current player',
        'They have rolled a 3',
        'Sue\'s new location is 3',
        'The category is Rock',
        'Rock Question 1',
        'Answer was corrent!!!!',
        'Sue now has 1 Gold Coins.',
        'Chet is the current player',
        'They have rolled a 2',
        'Chet\'s new location is 5',
        'The category is Science',
        'Science Question 0',
        'Answer was corrent!!!!',
        'Chet now has 2 Gold Coins.',
        'Pat is the current player',
        'They have rolled a 2',
        'Pat\'s new location is 4',
        'The category is Pop',
        'Pop Question 0',
        'Answer was corrent!!!!',
        'Pat now has 2 Gold Coins.',
        'Sue is the current player',
        'They have rolled a 1',
        'Sue\'s new location is 4',
        'The category is Pop',
        'Pop Question 1',
        'Answer was corrent!!!!',
        'Sue now has 2 Gold Coins.',
        'Chet is the current player',
        'They have rolled a 5',
        'Chet\'s new location is 10',
        'The category is Sports',
        'Sports Question 1',
        'Answer was corrent!!!!',
        'Chet now has 3 Gold Coins.',
        'Pat is the current player',
        'They have rolled a 1',
        'Pat\'s new location is 5',
        'The category is Science',
        'Science Question 1',
        'Answer was corrent!!!!',
        'Pat now has 3 Gold Coins.',
        'Sue is the current player',
        'They have rolled a 2',
        'Sue\'s new location is 6',
        'The category is Sports',
        'Sports Question 2',
        'Question was incorrectly answered',
        'Sue was sent to the penalty box',
        'Chet is the current player',
        'They have rolled a 4',
        'Chet\'s new location is 2',
        'The category is Sports',
        'Sports Question 3',
        'Answer was corrent!!!!',
        'Chet now has 4 Gold Coins.',
        'Pat is the current player',
        'They have rolled a 5',
        'Pat\'s new location is 10',
        'The category is Sports',
        'Sports Question 4',
        'Question was incorrectly answered',
        'Pat was sent to the penalty box',
        'Sue is the current player',
        'They have rolled a 3',
        'Sue is getting out of the penalty box',
        'Sue\'s new location is 9',
        'The category is Science',
        'Science Question 2',
        'Answer was correct!!!!',
        'Sue now has 3 Gold Coins.',
        'Chet is the current player',
        'They have rolled a 1',
        'Chet\'s new location is 3',
        'The category is Rock',
        'Rock Question 2',
        'Answer was corrent!!!!',
        'Chet now has 5 Gold Coins.',
        'Pat is the current player',
        'They have rolled a 2',
        'Pat is not getting out of the penalty box',
        'Sue is the current player',
        'They have rolled a 5',
        'Sue is getting out of the penalty box',
        'Sue\'s new location is 2',
        'The category is Sports',
        'Sports Question 5',
        'Answer was correct!!!!',
        'Sue now has 4 Gold Coins.',
        'Chet is the current player',
        'They have rolled a 2',
        'Chet\'s new location is 5',
        'The category is Science',
        'Science Question 3',
        'Answer was corrent!!!!',
        'Chet now has 6 Gold Coins.',
      ],
    }
  ].freeze
end

