require_relative './console_output'
require_relative './player'
require_relative './trivia_players'
require_relative './game_notifier'
require_relative './categorized_questions'

module UglyTrivia
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
