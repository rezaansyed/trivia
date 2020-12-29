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
