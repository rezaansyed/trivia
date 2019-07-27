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
      @output = output
    end

    def roll(roll)
      roll_result = start_turn.roll_result

      roll_result.roll = roll

      if @penalty_box.holding?(current_player)
        if roll.odd?
          roll_result.suspend_penalty

          apply_roll(roll_result)
        else
          roll_result.apply_penalty
        end
      else
        apply_roll(roll_result)
      end

      notify_roll_result(roll_result)
    end

    def was_correctly_answered
      answer_result = turn_tracking.answer_result

      answer_result.question_answered_correctly

      unless turn_tracking.penalty_applied?
        answer_result.coins_increase_to = current_player.purse.add_coin
      end

      notify_answer_result(answer_result)
      complete_turn
    end

    def notify_answer_result(answer_result)
      if answer_result.answered_incorrectly?
        notify_wrong_answer
      elsif answer_result.rewarded?
        notify_correct_anwser(answer_result)
      end
    end

    def wrong_answer
      answer_result = turn_tracking.answer_result

      answer_result.question_answered_incorrectly

      @penalty_box.hold(current_player)


      notify_answer_result(answer_result)
      complete_turn
    end

    private

    def start_turn
      @turn_tracking = Turn.new
    end

    attr_reader :turn_tracking

    def complete_turn
      @players.move_to_next_player

      !@players.winner?
    end

    def apply_roll(roll_result)
      roll = roll_result.roll

      roll_result.location_update = current_player.board_location.move(roll)

      question = @questions.next_question(roll_result.location_update.category)
      roll_result.question = question
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

    def notify_correct_anwser(answer_result)
      @output.write 'Answer was correct!!!!'
      @output.write "#{current_player} now has #{answer_result.coins_increase_to} Gold Coins."
    end

    def notify_question(roll_result)
      @output.write roll_result.question
    end

    def notify_not_getting_out_of_penalty_box
      @output.write "#{current_player} is not getting out of the penalty box"
    end

    def notify_location(roll_results)
      @output.write "#{current_player}'s new location is #{roll_results.location_update.new_location}"
      @output.write "The category is #{roll_results.location_update.category}"
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
  end

  class BoardLocation
    def initialize(categories)
      @categories = categories
      @location = 0
    end

    def move(roll)
      @location += roll
      @location = @location % 12

      LocationUpdate.new(@location, pointing_at_category)
    end

    def to_s
      @location.to_s
    end

    private

    def pointing_at_category
      @categories[@location % @categories.length]
    end
  end

  class LocationUpdate
    attr_reader :new_location
    attr_reader :category

    def initialize(new_location, category)
      @new_location = new_location
      @category = category
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

  class Turn
    attr_reader :roll_result
    attr_reader :answer_result

    def initialize
      @roll_result = RollResult.new
      @answer_result = AnswerResult.new
    end

    def penalty_applied?
      @roll_result.penalty_applied?
    end
  end

  class AnswerResult
    attr_accessor :coins_increase_to

    def initialize
      @answer = :not_answered
    end

    def rewarded?
      !coins_increase_to.nil?
    end

    def question_answered_correctly
      @answer = :correct
    end

    def question_answered_incorrectly
      @answer = :incorrect
    end

    def answered_correctly?
      @answer == :correct
    end

    def answered_incorrectly?
      @answer == :incorrect
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
