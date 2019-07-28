require_relative 'player'
require_relative 'player_rotation'
require_relative 'board_location'
require_relative 'purse'
require_relative 'categorized_questions'
require_relative 'game_play'

module UglyTrivia
  class Game
    def initialize(output = ConsoleOutput.new)
      @output = output

      @players = PlayerRotation.new

      @categories = ['Pop', 'Science', 'Sports', 'Rock']

      @questions = CategorizedQuestions.new(@categories)

      50.times do |i|
        @questions.add('Pop', "Pop Question #{i}")
        @questions.add('Science', "Science Question #{i}")
        @questions.add('Sports', "Sports Question #{i}")
        @questions.add('Rock', "Rock Question #{i}")
      end
    end

    def is_playable?
      @players.number_of_players >= 2
    end

    def add(player_name)
      player = Player.new(
        player_name,
        BoardLocation.new(@categories),
        Purse.new
      )

      @players.add player

      notify_player_added(player, @players.number_of_players)

      true
    end

    def roll(roll)
      game_play.roll(roll)
    end

    def was_correctly_answered
      game_play.was_correctly_answered
    end

    def wrong_answer
      game_play.wrong_answer
    end

    private

    def game_play
      @game_play ||= GamePlay.new(
        players: @players,
        questions: @questions,
        output: @output,
      )
    end

    def notify_player_added(player, number)
      @output.write "#{player} was added"
      @output.write "They are player number #{number}"
    end
  end
end
