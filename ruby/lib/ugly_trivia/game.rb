module UglyTrivia
  class Game
    def initialize(output = ConsoleOutput.new)
      @output = output

      @players = PlayerRotation.new

      @categories = ['Pop', 'Science', 'Sports', 'Rock']

      @questions = CategorizedQuestions.new(@categories)

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

      if @penalty_box.holding?(roll_result.player)
        if roll.odd?
          roll_result.suspend_penalty
        else
          roll_result.apply_penalty
        end
      end

      apply_roll(roll_result) unless roll_result.penalty_applied?

      complete_roll_step
    end

    def was_correctly_answered
      answer_result = turn.answer_result

      answer_result.question_answered_correctly

      unless turn.penalty_applied?
        answer_result.coins_increase_to = answer_result.player.purse.add_coin
      end

      complete_turn
    end

    def wrong_answer
      answer_result = turn.answer_result

      answer_result.question_answered_incorrectly

      @penalty_box.hold(answer_result.player)

      complete_turn
    end

    private

    def start_turn
      @turn = Turn.new(@players.current_player)
      @turn_notifier = TurnNotifier.new(@output, @turn)
      @turn
    end

    attr_reader :turn

    def complete_turn
      notify_turn_completion

      prepare_for_next_turn

      game_continues?
    end

    def game_continues?
      !@players.winner?
    end

    def prepare_for_next_turn
      @turn = nil
      @turn_notifier = nil

      @players.move_to_next_player
    end

    def notify_turn_completion
      @turn_notifier.notify_answer_result
    end

    def complete_roll_step
      @turn_notifier.notify_roll_result
    end

    def apply_roll(roll_result)
      roll = roll_result.roll

      roll_result.location_update = roll_result.player.board_location.move(roll)

      question = @questions.next_question(roll_result.location_update.category)
      roll_result.question = question
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

    def initialize(player)
      @roll_result = RollResult.new(player)
      @answer_result = AnswerResult.new(player)
    end

    def penalty_applied?
      @roll_result.penalty_applied?
    end
  end

  class AnswerResult
    attr_accessor :coins_increase_to
    attr_reader :player

    def initialize(player)
      @answer = :not_answered
      @player = player
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
    attr_accessor :category
    attr_accessor :location_update
    attr_accessor :question
    attr_reader :player

    def initialize(player)
      @penalty_status = :no_penalty
      @player = player
    end

    def suspend_penalty
      @penalty_status = :suspended
    end

    def apply_penalty
      @penalty_status = :applied
    end

    def penalty_applied?
      @penalty_status == :applied
    end

    def penalty_suspended?
      @penalty_status == :suspended
    end
  end

  class TurnNotifier
    def initialize(output, turn)
      @output = output
      @turn = turn
    end

    def notify_roll_result
      notify_roll

      if roll_result.penalty_applied?
        notify_not_getting_out_of_penalty_box
      else
        notify_getting_out_penalty_box if roll_result.penalty_suspended?
        notify_location
        notify_question
      end
    end

    def notify_answer_result(r = nil)
      if answer_result.answered_incorrectly?
        notify_wrong_answer
      elsif answer_result.rewarded?
        notify_correct_anwser
      end
    end

    private

    def roll_result
      @turn.roll_result
    end

    def answer_result
      @turn.answer_result
    end

    def notify_correct_anwser
      @output.write 'Answer was correct!!!!'
      @output.write "#{answer_result.player} now has #{answer_result.coins_increase_to} Gold Coins."
    end

    def notify_question
      @output.write roll_result.question
    end

    def notify_not_getting_out_of_penalty_box
      @output.write "#{roll_result.player} is not getting out of the penalty box"
    end

    def notify_location
      @output.write "#{roll_result.player}'s new location is #{roll_result.location_update.new_location}"
      @output.write "The category is #{roll_result.location_update.category}"
    end

    def notify_getting_out_penalty_box
      @output.write "#{roll_result.player} is getting out of the penalty box"
    end

    def notify_wrong_answer
      @output.write 'Question was incorrectly answered'
      @output.write "#{answer_result.player} was sent to the penalty box"
    end

    def notify_roll
      @output.write "#{roll_result.player} is the current player"
      @output.write "They have rolled a #{roll_result.roll}"
    end
  end
end
