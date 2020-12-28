require_relative './console_output'

module UglyTrivia
  class Game
    attr_accessor :players

    def  initialize(output = ConsoleOutput.new)
      @output = output
      @players = []
      @places = Array.new(6, 0)
      @purses = Array.new(6, 0)
      @in_penalty_box = Array.new(6, nil)

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
      players.push player_name
      @places[players.length] = 0
      @purses[players.length] = 0
      @in_penalty_box[players.length] = false

      @output.write "#{player_name} was added"
      @output.write "They are player number #{players.length}"

      true
    end

    def how_many_players
      @players.length
    end

    def roll(roll)
      @output.write "#{@players[@current_player]} is the current player"
      @output.write "They have rolled a #{roll}"

      if @in_penalty_box[@current_player]
        if roll % 2 != 0
          @is_getting_out_of_penalty_box = true

          @output.write "#{@players[@current_player]} is getting out of the penalty box"
          @places[@current_player] = @places[@current_player] + roll
          @places[@current_player] = @places[@current_player] - 12 if @places[@current_player] > 11

          @output.write "#{@players[@current_player]}'s new location is #{@places[@current_player]}"
          @output.write "The category is #{current_category}"
          ask_question
        else
          @output.write "#{@players[@current_player]} is not getting out of the penalty box"
          @is_getting_out_of_penalty_box = false
        end
      else
        @places[@current_player] = @places[@current_player] + roll
        @places[@current_player] = @places[@current_player] - 12 if @places[@current_player] > 11

        @output.write "#{@players[@current_player]}'s new location is #{@places[@current_player]}"
        @output.write "The category is #{current_category}"
        ask_question
      end
    end

    def was_correctly_answered
      if @in_penalty_box[@current_player]
        if @is_getting_out_of_penalty_box
          @output.write 'Answer was correct!!!!'
          @purses[@current_player] += 1

          @output.write "#{@players[@current_player]} now has #{@purses[@current_player]} Gold Coins."

          winner = did_player_win()

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
        @purses[@current_player] += 1
        @output.write "#{@players[@current_player]} now has #{@purses[@current_player]} Gold Coins."

        winner = did_player_win
        @current_player += 1
        @current_player = 0 if @current_player == @players.length

        return winner
      end
    end

    def wrong_answer
      @output.write 'Question was incorrectly answered'
      @output.write "#{@players[@current_player]} was sent to the penalty box"
      @in_penalty_box[@current_player] = true

      @current_player += 1
      @current_player = 0 if @current_player == @players.length
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
      return 'Pop' if @places[@current_player] == 0
      return 'Pop' if @places[@current_player] == 4
      return 'Pop' if @places[@current_player] == 8
      return 'Science' if @places[@current_player] == 1
      return 'Science' if @places[@current_player] == 5
      return 'Science' if @places[@current_player] == 9
      return 'Sports' if @places[@current_player] == 2
      return 'Sports' if @places[@current_player] == 6
      return 'Sports' if @places[@current_player] == 10
      return 'Rock'
    end

    def did_player_win
      !(@purses[@current_player] == 6)
    end
  end
end
