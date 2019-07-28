module UglyTrivia
  class Purse
    def initialize
      @coins = 0
    end

    def add_coin
      @coins += 1

      RewardChange.new(total)
    end

    def total
      @coins
    end

    def to_s
      @coins.to_s
    end
  end

  class RewardChange
    def initialize(total_coins)
      @total_coins = total_coins
    end

    def to_s
      @total_coins.to_s
    end
  end
end
