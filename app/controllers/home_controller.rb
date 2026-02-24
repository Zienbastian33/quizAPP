class HomeController < ApplicationController
  def index
    @published_quizzes = Quiz.published.recent.limit(6)
    @total_published = Quiz.published.count
  end
end
