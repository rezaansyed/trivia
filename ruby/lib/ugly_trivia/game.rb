module UglyTrivia
  class Game
    def initialize(output = ConsoleOutput.new)
      @output = output

      @players = []
      @places = []
      @purses = Array.new(6, 0)
      @penalty_box = PenaltyBox.new

      @pop_questions = []
      @science_questions = []
      @sports_questions = []
      @rock_questions = []

      @current_player_position = 0
      @is_getting_out_of_penalty_box = false

      50.times do |i|
        @pop_questions.push "Pop Question #{i}"
        @science_questions.push "Science Question #{i}"
        @sports_questions.push "Sports Question #{i}"
        @rock_questions.push "Rock Question #{i}"
      end
    end

    def is_playable?
      how_many_players >= 2
    end

    def add(player_name)
      @players.push Player.new(player_name)
      @places.push BoardLocation.new

      @output.write "#{player_name} was added"
      @output.write "They are player number #{@players.length}"

      true
    end

    def how_many_players
      @players.length
    end

    def roll(roll)
      @output.write "#{current_player} is the current player"
      @output.write "They have rolled a #{roll}"

      if current_player_in_penalty_box?
        if roll.odd?
          @is_getting_out_of_penalty_box = true

          @output.write "#{current_player} is getting out of the penalty box"

          move_current_players_position(roll)

          @output.write "#{current_player}'s new location is #{@places[@current_player_position]}"
          @output.write "The category is #{current_category}"
          ask_question
        else
          @output.write "#{current_player} is not getting out of the penalty box"
          @is_getting_out_of_penalty_box = false
        end
      else
        move_current_players_position(roll)

        @output.write "#{current_player}'s new location is #{@places[@current_player_position]}"
        @output.write "The category is #{current_category}"
        ask_question
      end
    end

    def was_correctly_answered
      if current_player_in_penalty_box?
        if @is_getting_out_of_penalty_box
          @output.write 'Answer was correct!!!!'
          @purses[@current_player_position] += 1
          @output.write "#{current_player} now has #{@purses[@current_player_position]} Gold Coins."

          move_to_next_player

          game_continues?
        else
          move_to_next_player
          true
        end
      else
        @output.write "Answer was correct!!!!"
        @purses[@current_player_position] += 1
        @output.write "#{current_player} now has #{@purses[@current_player_position]} Gold Coins."

        move_to_next_player

        game_continues?
      end
    end

    def wrong_answer
      @output.write 'Question was incorrectly answered'
      @output.write "#{current_player} was sent to the penalty box"
  		put_current_player_in_the_penalty_box

      @current_player_position += 1
      @current_player_position = 0 if @current_player_position == @players.length
  		return true
    end

    private

    def current_player
      @players[@current_player_position]
    end

    def current_player_in_penalty_box?
      @penalty_box.holding?(current_player)
    end

    def put_current_player_in_the_penalty_box
      @penalty_box.hold(current_player)
    end

    def move_to_next_player
      @current_player_position += 1
      @current_player_position = 0 if @current_player_position == @players.length
    end

    def ask_question
      @output.write @pop_questions.shift if current_category == 'Pop'
      @output.write @science_questions.shift if current_category == 'Science'
      @output.write @sports_questions.shift if current_category == 'Sports'
      @output.write @rock_questions.shift if current_category == 'Rock'
    end

    def current_category
      return 'Pop' if @places[@current_player_position].square == 0
      return 'Pop' if @places[@current_player_position].square == 4
      return 'Pop' if @places[@current_player_position].square == 8
      return 'Science' if @places[@current_player_position].square == 1
      return 'Science' if @places[@current_player_position].square == 5
      return 'Science' if @places[@current_player_position].square == 9
      return 'Sports' if @places[@current_player_position].square == 2
      return 'Sports' if @places[@current_player_position].square == 6
      return 'Sports' if @places[@current_player_position].square == 10
      return 'Rock'
    end

    def game_continues?
      @purses.none? { |purse| purse == 6 }
    end

    def move_current_players_position(roll)
      @places[@current_player_position].move(roll)
    end
  end

  class BoardLocation
    attr_reader :square

    def initialize
      @square = 0
    end

    def move(roll)
      @square += roll
      @square = @square % 12
    end

    def to_s
      @square.to_s
    end
  end

  class ConsoleOutput
    def write(line)
      puts line
    end
  end

  class PenaltyBox
    def initialize
      @players = Set.new
    end

    def hold(player)
      @players << player
    end

    def holding?(player)
      @players.include?(player)
    end
  end

  class Player
    def initialize(name)
      @name = name
    end

    def to_s
      @name
    end

    def ==(other)
      other.class == self.class &&
        other.to_s == to_s
    end
  end
end
