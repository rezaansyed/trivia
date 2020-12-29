require_relative './console_output'
require_relative './player'
require_relative './trivia_players'

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

module UglyTrivia
  class CategorizedQuestions
    def initialize
      @questions = {}
    end

    def add_question(category:, question:)
      @questions[category] ||= []
      @questions[category] << question
    end

    def get_question(category:)
      @questions[category].shift
    end
  end
  class Game
    include GameNotifier

    attr_accessor :players

    def initialize(output = ConsoleOutput.new)
      @output = output
      @players = TriviaPlayers.new
      @questions = CategorizedQuestions.new

      @is_getting_out_of_penalty_box = false

      50.times do |i|
        @questions.add_question(category: 'Pop', question: "Pop Question #{i}")
        @questions.add_question(category: 'Science', question: "Science Question #{i}")
        @questions.add_question(category: 'Sports', question: "Sports Question #{i}")
        @questions.add_question(category: 'Rock', question: "Rock Question #{i}")
      end
    end

    def is_playable?
      players.length > 1
    end

    def add(player_name)
      new_player = Player.new(name: player_name)
      players.add new_player
      notify_player_added(player: new_player, number_of_players: players.length)
    end

    def in_penalty_box_with_even_roll(roll)
      current_player.in_penalty_box? && roll.even?
    end

    def skip_turn
      notify_player_not_getting_out_of_penalty(current_player)
      @is_getting_out_of_penalty_box = false
    end

    def roll(roll)
      notify_current_player_roll(player: current_player, roll: roll)

      # Check roll value
      return skip_turn if in_penalty_box_with_even_roll(roll)


      if current_player.in_penalty_box?
        @is_getting_out_of_penalty_box = true
        notify_player_getting_out_of_box(current_player)
      end


      # Update locationment
      current_player.location.move(roll)
      notify_new_location(current_player)

      # Ask question
      ask_question
    end

    def was_correctly_answered
      if current_player.in_penalty_box? && !@is_getting_out_of_penalty_box
        next_player
        return true
      end

      notify_correct_answer
      current_player.purse += 1
      notify_coins_in_purse(current_player)

      winner = did_player_win

      next_player

      winner
    end

    def wrong_answer
      current_player.place_in_penalty_box
      notify_wrong_answer(current_player)
      next_player
      return true
    end

    private

    def current_player
      players.current_player
    end

    def next_player
      players.next_player
    end

    def ask_question
      category = current_player.location.category
      question = @questions.get_question(category: current_player.location.category)
      notify_question(category: category, question: question)
    end

    def did_player_win
      !(current_player.purse == 6)
    end
  end
end
