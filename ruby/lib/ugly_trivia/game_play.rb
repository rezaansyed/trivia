require_relative 'penalty_box'
require_relative 'turn'
require_relative 'turn_notifier'

module UglyTrivia
  class GamePlay
    def initialize(players:, questions:, output:)
      @players = players
      @questions = questions
      @penalty_box = PenaltyBox.new
      @output = output
    end

    def roll(roll)
      turn = start_turn(roll)

      penalty_box.adjust_penalty_for_roll(turn)

      penalty_box.run_when_no_penalty(turn) do |t|
        apply_roll(t)
      end

      complete_roll_step
    end

    def was_correctly_answered
      answer_result = turn.answer_result

      answer_result.question_answered_correctly

      penalty_box.run_when_no_penalty(turn) do |turn|
        turn.answer_result.coins_increase_to = turn.player.purse.add_coin
      end

      complete_turn
    end

    def wrong_answer
      turn.answer_result.question_answered_incorrectly

      penalty_box.hold(turn.player)

      complete_turn
    end

    private

    attr_reader :turn
    attr_reader :players
    attr_reader :penalty_box

    def start_turn(roll)
      @turn = Turn.new(players.current_player, roll)
      @turn_notifier = TurnNotifier.new(@output, @turn)
      @turn
    end

    def complete_turn
      notify_turn_completion

      prepare_for_next_turn

      game_continues?
    end

    def game_continues?
      !players.winner?
    end

    def prepare_for_next_turn
      clear_turn_storage
      players.move_to_next_player
    end

    def clear_turn_storage
      @turn = nil
      @turn_notifier = nil
    end

    def notify_turn_completion
      @turn_notifier.notify_answer_result
    end

    def complete_roll_step
      @turn_notifier.notify_roll_result
    end

    def apply_roll(turn)
      location_update = turn.player.board_location.move(turn.roll)

      turn.roll_result.location_update = location_update

      turn.roll_result.question = @questions.next_question(location_update.category)
    end
  end
end
