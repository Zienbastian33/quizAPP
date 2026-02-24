module Admin
  class DashboardController < Admin::BaseController
    def index
      @total_quizzes = current_user.quizzes.count
      @published_quizzes = current_user.quizzes.published.count
      @draft_quizzes = current_user.quizzes.drafts.count
      @total_questions = Question.joins(:quiz).where(quizzes: { user_id: current_user.id }).count
      @total_attempts = QuizAttempt.joins(:quiz).where(quizzes: { user_id: current_user.id }).count
      @recent_quizzes = current_user.quizzes.recent.limit(5)
    end
  end
end
