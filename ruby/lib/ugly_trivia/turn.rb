module UglyTrivia
  class Turn
    attr_reader :roll_result
    attr_reader :answer_result
    attr_reader :player
    attr_reader :roll

    def initialize(player, roll)
      @player = player
      @roll = roll
      @roll_result = RollResult.new
      @answer_result = AnswerResult.new
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
      @penalty_status == :applied
    end

    def penalty_suspended?
      @penalty_status == :suspended
    end
  end
end
