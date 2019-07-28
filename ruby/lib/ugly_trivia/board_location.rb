module UglyTrivia
  class BoardLocation
    def initialize(categories)
      @categories = categories
      @location = 0
    end

    def move(roll)
      @location += roll
      @location = @location % 12

      LocationUpdate.new(@location, pointing_at_category)
    end

    def to_s
      @location.to_s
    end

    private

    def pointing_at_category
      @categories[@location % @categories.length]
    end
  end

  class LocationUpdate
    attr_reader :new_location
    attr_reader :category

    def initialize(new_location, category)
      @new_location = new_location
      @category = category
    end
  end
end
