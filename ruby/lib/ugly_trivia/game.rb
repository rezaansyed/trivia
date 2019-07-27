module UglyTrivia
  class Game
    def initialize(output = ConsoleOutput.new)
      @output = output

      @players = PlayerRotation.new

      @categories = ['Pop', 'Science', 'Sports', 'Rock']

      @questions = CategorizedQuestions.new(@categories)
      @current_player_position = 0

      50.times do |i|
        @questions.add('Pop', "Pop Question #{i}")
        @questions.add('Science', "Science Question #{i}")
        @questions.add('Sports', "Sports Question #{i}")
        @questions.add('Rock', "Rock Question #{i}")
      end
    end

    def is_playable?
      @players.number_of_players >= 2
    end

    def add(player_name)
      player = Player.new(
        player_name,
        BoardLocation.new(@categories),
        Purse.new
      )

      @players.add player

      notify_player_added(player, @players.number_of_players)

      true
    end

    def roll(roll)
      game_play.roll(roll)
    end

    def was_correctly_answered
      game_play.was_correctly_answered
    end

    def wrong_answer
      game_play.wrong_answer
    end

    private

    def game_play
      @game_play ||= GamePlay.new(
        players: @players,
        questions: @questions,
        output: @output,
      )
    end

    def notify_player_added(player, number)
      @output.write "#{player} was added"
      @output.write "They are player number #{number}"
    end
  end

  class GamePlay
    def initialize(players:, questions:, output:)
      @players = players
      @questions = questions
      @penalty_box = PenaltyBox.new
      @is_getting_out_of_penalty_box = false

      @output = output
    end

    def roll(roll)
      roll_result = RollResult.new
      roll_result.roll = roll

      if @penalty_box.holding?(current_player)
        if roll.odd?
          @is_getting_out_of_penalty_box = true
          roll_result.suspend_penalty

          apply_roll(roll_result)
        else
          roll_result.apply_penalty
          @is_getting_out_of_penalty_box = false
        end
      else
        apply_roll(roll_result)
      end

      notify_roll_result(roll_result)
    end

    def was_correctly_answered
      unless penalty_applied?
        current_player.purse.add_coin

        notify_correct_anwser
      end

      complete_turn
    end

    def wrong_answer
      @penalty_box.hold(current_player)

      notify_wrong_answer

      complete_turn
    end

    private

    def penalty_applied?
      @penalty_box.holding?(current_player) && !@is_getting_out_of_penalty_box
    end

    def complete_turn
      @players.move_to_next_player

      !@players.winner?
    end

    def apply_roll(roll_results)
      roll = roll_results.roll

      roll_results.location_update = current_player.board_location.move(roll)
      # temporal coupling with the move first.
      roll_results.category = current_category

      question = @questions.next_question(current_category)
      roll_results.question = question
    end

    def notify_roll_result(roll_result)
      notify_roll(roll_result.roll)

      if roll_result.penalty_applied?
        notify_not_getting_out_of_penalty_box
      else
        notify_getting_out_penalty_box if roll_result.penalty_suspended?
        notify_location(roll_result)
        notify_question(roll_result)
      end
    end

    def notify_correct_anwser
      @output.write 'Answer was correct!!!!'
      @output.write "#{current_player} now has #{current_player.purse} Gold Coins."
    end

    def notify_question(roll_result)
      @output.write roll_result.question
    end

    def notify_not_getting_out_of_penalty_box
      @output.write "#{current_player} is not getting out of the penalty box"
    end

    def notify_location(roll_results)
      @output.write "#{current_player}'s new location is #{roll_results.location_update}"
      @output.write "The category is #{roll_results.category}"
    end

    def notify_getting_out_penalty_box
      @output.write "#{current_player} is getting out of the penalty box"
    end

    def notify_wrong_answer
      @output.write 'Question was incorrectly answered'
      @output.write "#{current_player} was sent to the penalty box"
    end

    def notify_roll(roll)
      @output.write "#{current_player} is the current player"
      @output.write "They have rolled a #{roll}"
    end

    def current_player
      @players.current_player
    end

    def current_category
      current_player.board_location.pointing_at_category
    end
  end

  class BoardLocation
    attr_reader :square

    def initialize(categories)
      @categories = categories
      @square = 0
    end

    def pointing_at_category
      @categories[square % @categories.length]
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
    attr_reader :purse
    attr_reader :board_location

    def initialize(name, board_location, purse)
      @name = name
      @purse = purse
      @board_location = board_location
    end

    def to_s
      @name
    end

    def ==(other)
      other.class == self.class &&
        other.to_s == to_s
    end
  end

  class CategorizedQuestions
    def initialize(categories)
      @questions = Hash[categories.map { |c| [c, []] }]
    end

    def add(category, question)
      @questions[category] << question
    end

    def next_question(category)
      @questions[category].shift
    end
  end

  class Purse
    def initialize
      @coins = 0
    end

    def add_coin
      @coins += 1
    end

    def total
      @coins
    end

    def to_s
      @coins.to_s
    end
  end

  class PlayerRotation
    def initialize
      @players = []
    end

    def add(player)
      @players << player
    end

    def winner?
      @players.any? { |player| player.purse.total == 6 }
    end

    def number_of_players
      @players.length
    end

    def current_player
      @players.first
    end

    def move_to_next_player
      @players.rotate!
    end
  end

  class RollResult
    attr_accessor :roll
    attr_accessor :penalty_status
    attr_accessor :category
    attr_accessor :location_update
    attr_accessor :question

    def initialize
      @penalty_status = :no_penalty
    end

    def suspend_penalty
      @penalty_status = :suspended
    end

    def apply_penalty
      @penalty_status = :applied
    end

    def penalty_applied?
      penalty_status == :applied
    end

    def penalty_suspended?
      penalty_status == :suspended
    end
  end
end
