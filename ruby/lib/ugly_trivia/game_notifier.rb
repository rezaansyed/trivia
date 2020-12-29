module GameNotifier
  def notify_player_added(player: , number_of_players: )
    @output.write "#{player.name} was added"
    @output.write "They are player number #{number_of_players}"
  end

  def notify_current_player_roll(player:, roll:)
    @output.write "#{player.name} is the current player"
    @output.write "They have rolled a #{roll}"
  end

  def notify_wrong_answer(player)
    @output.write 'Question was incorrectly answered'
    @output.write "#{player.name} was sent to the penalty box"
  end

  def notify_correct_answer
    @output.write 'Answer was correct!!!!'
  end

  def notify_coins_in_purse(player)
    @output.write "#{player.name} now has #{player.purse} Gold Coins."
  end

  def notify_question(category:, question:)
    @output.write "The category is #{category}"
    @output.write question
  end

  def notify_player_not_getting_out_of_penalty(player)
    @output.write "#{player.name} is not getting out of the penalty box"
  end

  def notify_player_getting_out_of_box(player)
    @output.write "#{player.name} is getting out of the penalty box"
  end

  def notify_new_location(player)
    @output.write "#{player.name}'s new location is #{player.location}"
  end
end
