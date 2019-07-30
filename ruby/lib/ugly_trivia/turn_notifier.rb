module UglyTrivia
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

    def notify_answer_result
      if answer_result.answered_incorrectly?
        notify_wrong_answer
      elsif answer_result.rewarded?
        notify_correct_anwser
      end
    end

    private

    attr_reader :turn

    def roll_result
      turn.roll_result
    end

    def answer_result
      turn.answer_result
    end

    def notify_correct_anwser
      @output.write 'Answer was correct!!!!'
      @output.write "#{turn.player} now has #{answer_result.coins_increase_to} Gold Coins."
    end

    def notify_question
      @output.write roll_result.question
    end

    def notify_not_getting_out_of_penalty_box
      @output.write "#{turn.player} is not getting out of the penalty box"
    end

    def notify_location
      @output.write "#{turn.player}'s new location is #{roll_result.location_update.new_location}"
      @output.write "The category is #{roll_result.location_update.category}"
    end

    def notify_getting_out_penalty_box
      @output.write "#{turn.player} is getting out of the penalty box"
    end

    def notify_wrong_answer
      @output.write 'Question was incorrectly answered'
      @output.write "#{turn.player} was sent to the penalty box"
    end

    def notify_roll
      @output.write "#{turn.player} is the current player"
      @output.write "They have rolled a #{turn.roll}"
    end
  end
end
