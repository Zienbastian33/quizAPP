class AttemptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quiz
  before_action :set_attempt, only: [:show, :submit]

  # POST /quizzes/:quiz_id/attempts
  def create
    existing = current_user.quiz_attempts
                 .where(quiz: @quiz, status: :in_progress).first
    if existing
      redirect_to quiz_attempt_path(@quiz, existing),
        notice: "Ya tienes un intento en progreso."
      return
    end

    @attempt = @quiz.quiz_attempts.build(user: current_user)

    if @attempt.save
      redirect_to quiz_attempt_path(@quiz, @attempt),
        notice: "¡Quiz iniciado! Responde las preguntas."
    else
      redirect_to quiz_path(@quiz),
        alert: @attempt.errors.full_messages.join(", ")
    end
  end

  # GET /quizzes/:quiz_id/attempts/:id
  def show
    @questions = @quiz.questions.includes(:options).ordered
    @answered_ids = @attempt.attempt_answers.pluck(:question_id)
    @total_questions = @questions.count
    @answered_count = @answered_ids.count
  end

  # POST /quizzes/:quiz_id/attempts/:id/submit
  def submit
    if @attempt.in_progress?
      @attempt.calculate_score!
      redirect_to quiz_attempt_path(@quiz, @attempt),
        notice: "¡Quiz completado! Tu puntaje: #{@attempt.score}/#{@attempt.total_questions}"
    else
      redirect_to quiz_attempt_path(@quiz, @attempt),
        alert: "Este intento ya fue finalizado."
    end
  end

  private

  def set_quiz
    @quiz = Quiz.published.find(params[:quiz_id])
  end

  def set_attempt
    @attempt = current_user.quiz_attempts.find(params[:id])
  end
end
