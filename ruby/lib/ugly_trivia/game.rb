require_relative './console_output'
require_relative './player'
require_relative './trivia_players'

module UglyTrivia
  class Game
    attr_accessor :players

    def initialize(output = ConsoleOutput.new)
      @output = output
      @players = TriviaPlayers.new

      @pop_questions = []
      @science_questions = []
      @sports_questions = []
      @rock_questions = []

      @is_getting_out_of_penalty_box = false

      50.times do |i|
        @pop_questions.push "Pop Question #{i}"
        @science_questions.push "Science Question #{i}"
        @sports_questions.push "Sports Question #{i}"
        @rock_questions.push "Rock Question #{i}"
      end
    end

    def is_playable?
      players.length > 1
    end

    def add(player_name)
      players.add Player.new(name: player_name)

      @output.write "#{player_name} was added"
      @output.write "They are player number #{players.length}"

      true
    end

    def roll(roll)
      @output.write "#{current_player.name} is the current player"
      @output.write "They have rolled a #{roll}"

      if current_player.in_penalty_box?
        if roll % 2 != 0
          @is_getting_out_of_penalty_box = true

          @output.write "#{current_player.name} is getting out of the penalty box"
          current_player.roll(roll)

          @output.write "#{current_player.name}'s new location is #{current_player.place}"
          @output.write "The category is #{current_category}"
          ask_question
        else
          @output.write "#{current_player.name} is not getting out of the penalty box"
          @is_getting_out_of_penalty_box = false
        end
      else
        current_player.roll(roll)

        @output.write "#{current_player.name}'s new location is #{current_player.place}"
        @output.write "The category is #{current_category}"
        ask_question
      end
    end

    def was_correctly_answered
      if current_player.in_penalty_box?
        if @is_getting_out_of_penalty_box
          @output.write 'Answer was correct!!!!'
          current_player.purse += 1

          @output.write "#{current_player.name} now has #{current_player.purse} Gold Coins."

          winner = did_player_win

          next_player

          winner
        else
          next_player
          true
        end
      else
        @output.write "Answer was corrent!!!!"
        current_player.purse += 1
        @output.write "#{current_player.name} now has #{current_player.purse} Gold Coins."

        winner = did_player_win
        next_player

        return winner
      end
    end

    def wrong_answer
      @output.write 'Question was incorrectly answered'
      @output.write "#{current_player.name} was sent to the penalty box"
      current_player.place_in_penalty_box

      next_player
      return true
    end

    private

    def current_player
      players.current_player
    end

    def next_player
      players.next_player
    end

    def ask_question
      @output.write @pop_questions.shift if current_category == 'Pop'
      @output.write @science_questions.shift if current_category == 'Science'
      @output.write @sports_questions.shift if current_category == 'Sports'
      @output.write @rock_questions.shift if current_category == 'Rock'
    end

    def current_category
      return 'Pop' if current_player.place % 4 == 0
      return 'Science' if current_player.place % 4 == 1
      return 'Sports' if current_player.place % 4 == 2
      return 'Rock'
    end

    def did_player_win
      !(current_player.purse == 6)
    end
  end
end
