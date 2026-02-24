class QuizzesController < ApplicationController
  include Pagy::Method

  # GET /quizzes
  def index
    @pagy, @quizzes = pagy(:offset, Quiz.published.recent, limit: 12)
  end

  # GET /quizzes/:id
  def show
    @quiz = Quiz.published.find(params[:id])
    @questions = @quiz.questions.includes(:options).ordered
    @total_questions = @questions.count

    if user_signed_in?
      @existing_attempt = current_user.quiz_attempts
                            .where(quiz: @quiz, status: :in_progress).first
      @completed_attempts = current_user.quiz_attempts
                              .where(quiz: @quiz, status: :completed)
                              .order(created_at: :desc)
    end
  end
end
