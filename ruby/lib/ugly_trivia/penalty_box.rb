module UglyTrivia
  class PenaltyBox
    def initialize
      @players = Set.new
    end

    def hold(player)
      @players << player
    end

    def execute_when_clear_of_penalty(turn, &block)
      if holding?(turn.player)
        if turn.roll_result.roll.odd?
          turn.roll_result.suspend_penalty
        else
          turn.roll_result.apply_penalty
        end
      end

      unless turn.roll_result.penalty_applied?
        block.call(turn.roll_result)
      end
    end

    def reward_when_there_is_no_penalty_applied(turn, &block)
      unless turn.penalty_applied?
        block.call(turn.answer_result)
      end
    end

    private

    def holding?(player)
      @players.include?(player)
    end
  end
end
