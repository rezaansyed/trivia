module UglyTrivia
  class Game
    def initialize(output = ConsoleOutput.new)
      @output = output

      @players = PlayerRotation.new

      @categories = ['Pop', 'Science', 'Sports', 'Rock']

      @questions = CategorizedQuestions.new(@categories)
      @current_player_position = 0

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

  class GamePlay
    def initialize(players:, questions:, output:)
      @players = players
      @questions = questions
      @penalty_box = PenaltyBox.new
      @is_getting_out_of_penalty_box = false

      @output = output
    end

    def roll(roll)
      notify_roll(roll)

      if @penalty_box.holding?(current_player)
        if roll.odd?
          @is_getting_out_of_penalty_box = true

          notify_getting_out_penalty_box

          apply_roll(roll)
        else
          notify_not_getting_out_of_penalty_box

          @is_getting_out_of_penalty_box = false
        end
      else
        apply_roll(roll)
      end
    end

    def was_correctly_answered
      if @penalty_box.holding?(current_player)
        if @is_getting_out_of_penalty_box
          @output.write 'Answer was correct!!!!'

          current_player.purse.add_coin

          @output.write "#{current_player} now has #{current_player.purse} Gold Coins."

          @players.move_to_next_player

          game_continues?
        else
          @players.move_to_next_player
          true
        end
      else
        @output.write "Answer was correct!!!!"

        current_player.purse.add_coin

        @output.write "#{current_player} now has #{current_player.purse} Gold Coins."

        @players.move_to_next_player

        game_continues?
      end
    end

    def wrong_answer
      notify_wrong_answer

      @penalty_box.hold(current_player)

      @players.move_to_next_player

  		return true
    end

    private

    def apply_roll(roll)
      current_player.board_location.move(roll)

      notify_location(current_category)

      question = @questions.next_question(current_category)

      notify_question(question)
    end

    def notify_question(question)
      @output.write question
    end

    def notify_not_getting_out_of_penalty_box
      @output.write "#{current_player} is not getting out of the penalty box"
    end

    def notify_location(current_category)
      @output.write "#{current_player}'s new location is #{current_player.board_location}"
      @output.write "The category is #{current_category}"
    end

    def notify_getting_out_penalty_box
      @output.write "#{current_player} is getting out of the penalty box"
    end

    def notify_wrong_answer
      @output.write 'Question was incorrectly answered'
      @output.write "#{current_player} was sent to the penalty box"
    end

    def notify_roll(roll)
      @output.write "#{current_player} is the current player"
      @output.write "They have rolled a #{roll}"
    end

    def current_player
      @players.current_player
    end

    def current_category
      current_player.board_location.pointing_at_category
    end

    def game_continues?
      @players.none? { |player| player.purse.total == 6 }
    end
  end

  class BoardLocation
    attr_reader :square

    def initialize(categories)
      @categories = categories
      @square = 0
    end

    def pointing_at_category
      @categories[square % @categories.length]
    end

    def move(roll)
      @square += roll
      @square = @square % 12
    end

    def to_s
      @square.to_s
    end
  end

  class ConsoleOutput
    def write(line)
      puts line
    end
  end

  class PenaltyBox
    def initialize
      @players = Set.new
    end

    def hold(player)
      @players << player
    end

    def holding?(player)
      @players.include?(player)
    end
  end

  class Player
    attr_reader :purse
    attr_reader :board_location

    def initialize(name, board_location, purse)
      @name = name
      @purse = purse
      @board_location = board_location
    end

    def to_s
      @name
    end

    def ==(other)
      other.class == self.class &&
        other.to_s == to_s
    end
  end

  class CategorizedQuestions
    def initialize(categories)
      @questions = Hash[categories.map { |c| [c, []] }]
    end

    def add(category, question)
      @questions[category] << question
    end

    def next_question(category)
      @questions[category].shift
    end
  end

  class Purse
    def initialize
      @coins = 0
    end

    def add_coin
      @coins += 1
    end

    def total
      @coins
    end

    def to_s
      @coins.to_s
    end
  end

  class PlayerRotation
    include Enumerable

    def initialize
      @players = []
    end

    def add(player)
      @players << player
    end

    def each(&block)
      @players.each(&block)
    end

    def number_of_players
      @players.length
    end

    def current_player
      @players.first
    end

    def move_to_next_player
      @players.rotate!
    end
  end
end
