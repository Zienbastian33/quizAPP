module Api
  module V1
    class AnswersController < BaseController
      # POST /api/v1/attempts/:attempt_id/answers
      # Body: { "question_id": 1, "option_id": 3 }
      def create
        attempt = current_user.quiz_attempts.find(params[:attempt_id])

        unless attempt.in_progress?
          render json: { error: "Este intento ya fue finalizado" }, status: :unprocessable_entity
          return
        end

        question = attempt.quiz.questions.find(params[:question_id])
        option = question.options.find(params[:option_id])

        existing = attempt.attempt_answers.find_by(question: question)

        if existing
          existing.update!(option: option)
          render json: {
            data: answer_json(existing.reload),
            message: "Respuesta actualizada"
          }
        else
          answer = attempt.attempt_answers.build(
            question: question,
            option: option
          )

          if answer.save
            render json: { data: answer_json(answer) }, status: :created
          else
            render json: { errors: answer.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      private

      def answer_json(answer)
        {
          id: answer.id,
          attempt_id: answer.quiz_attempt_id,
          question_id: answer.question_id,
          option_id: answer.option_id,
          created_at: answer.created_at
          # NO incluimos "correct" para evitar trampas durante el quiz
        }
      end
    end
  end
end
