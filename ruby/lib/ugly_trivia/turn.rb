module UglyTrivia
  class Turn
    attr_reader :roll_result
    attr_reader :answer_result
    attr_reader :player

    def initialize(player, roll = nil)
      @player = player
      @roll = roll
      @roll_result = RollResult.new(player)
      @answer_result = AnswerResult.new(player)
    end

    def roll
      @roll || roll_result.roll
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
end
