module UglyTrivia
  class PenaltyBox
    def initialize
      @players = Set.new
    end

    def hold(player)
      @players << player
    end

    def adjust_penalty_for_roll(turn)
      if holding?(turn.player)
        if turn.roll_result.roll.odd?
          turn.roll_result.suspend_penalty
        else
          turn.roll_result.apply_penalty
        end
      end
    end

    def run_when_no_penalty(turn, &block)
      unless turn.penalty_applied?
        block.call(turn)
      end
    end

    private

    def holding?(player)
      @players.include?(player)
    end
  end
end
