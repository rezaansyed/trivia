require_relative './console_output'

module UglyTrivia
  class Player
    attr_reader :name, :place
    attr_accessor :purse

    def initialize(name:)
      @name = name
      @purse = 0
      @place = 0
      @in_penalty_box = false
    end

    def roll(roll_number)
      @place = (@place + roll_number) % 12
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
  end

  class Game
    attr_accessor :players, :purses

    def initialize(output = ConsoleOutput.new)
      @output = output
      @players = []

      @pop_questions = []
      @science_questions = []
      @sports_questions = []
      @rock_questions = []

      @current_player = 0
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
      players.push Player.new(name: player_name)

      @output.write "#{player_name} was added"
      @output.write "They are player number #{players.length}"

      true
    end

    def roll(roll)
      @output.write "#{players[@current_player].name} is the current player"
      @output.write "They have rolled a #{roll}"

      if players[@current_player].in_penalty_box?
        if roll % 2 != 0
          @is_getting_out_of_penalty_box = true

          @output.write "#{players[@current_player].name} is getting out of the penalty box"
          players[@current_player].roll(roll)

          @output.write "#{players[@current_player].name}'s new location is #{players[@current_player].place}"
          @output.write "The category is #{current_category}"
          ask_question
        else
          @output.write "#{players[@current_player].name} is not getting out of the penalty box"
          @is_getting_out_of_penalty_box = false
        end
      else
        players[@current_player].roll(roll)

        @output.write "#{@players[@current_player].name}'s new location is #{players[@current_player].place}"
        @output.write "The category is #{current_category}"
        ask_question
      end
    end

    def was_correctly_answered
      if players[@current_player].in_penalty_box?
        if @is_getting_out_of_penalty_box
          @output.write 'Answer was correct!!!!'
          players[@current_player].purse += 1

          @output.write "#{players[@current_player].name} now has #{players[@current_player].purse} Gold Coins."

          winner = did_player_win

          @current_player += 1
          @current_player = 0 if @current_player == @players.length

          winner
        else
          @current_player += 1
          @current_player = 0 if @current_player == @players.length
          true
        end
      else
        @output.write "Answer was corrent!!!!"
        players[@current_player].purse += 1
        @output.write "#{players[@current_player].name} now has #{players[@current_player].purse} Gold Coins."

        winner = did_player_win
        @current_player += 1
        @current_player = 0 if @current_player == @players.length

        return winner
      end
    end

    def wrong_answer
      @output.write 'Question was incorrectly answered'
      @output.write "#{@players[@current_player].name} was sent to the penalty box"
      players[@current_player].place_in_penalty_box

      @current_player += 1
      @current_player = 0 if @current_player == players.length
      return true
    end

    private

    def ask_question
      @output.write @pop_questions.shift if current_category == 'Pop'
      @output.write @science_questions.shift if current_category == 'Science'
      @output.write @sports_questions.shift if current_category == 'Sports'
      @output.write @rock_questions.shift if current_category == 'Rock'
    end

    def current_category
      return 'Pop' if players[@current_player].place == 0
      return 'Pop' if players[@current_player].place == 4
      return 'Pop' if players[@current_player].place == 8
      return 'Science' if players[@current_player].place == 1
      return 'Science' if players[@current_player].place == 5
      return 'Science' if players[@current_player].place == 9
      return 'Sports' if players[@current_player].place == 2
      return 'Sports' if players[@current_player].place == 6
      return 'Sports' if players[@current_player].place == 10
      return 'Rock'
    end

    def did_player_win
      !(players[@current_player].purse == 6)
    end
  end
end
