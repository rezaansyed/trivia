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
end
