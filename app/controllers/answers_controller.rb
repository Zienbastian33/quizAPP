class AnswersController < ApplicationController
  before_action :authenticate_user!

  # POST /quizzes/:quiz_id/attempts/:attempt_id/answers
  def create
    @quiz = Quiz.published.find(params[:quiz_id])
    @attempt = current_user.quiz_attempts.find(params[:attempt_id])

    unless @attempt.in_progress?
      redirect_to quiz_attempt_path(@quiz, @attempt),
        alert: "Este intento ya fue finalizado."
      return
    end

    question = @quiz.questions.find(params[:question_id])
    option = question.options.find(params[:option_id])

    existing = @attempt.attempt_answers.find_by(question: question)
    if existing
      existing.update!(option: option)
      redirect_to quiz_attempt_path(@quiz, @attempt),
        notice: "Respuesta actualizada."
    else
      answer = @attempt.attempt_answers.build(
        question: question,
        option: option
      )

      if answer.save
        redirect_to quiz_attempt_path(@quiz, @attempt),
          notice: "Respuesta guardada."
      else
        redirect_to quiz_attempt_path(@quiz, @attempt),
          alert: answer.errors.full_messages.join(", ")
      end
    end
  end
end
