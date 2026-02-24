module Api
  module V1
    class AttemptsController < BaseController
      before_action :set_attempt, only: [:show, :submit]

      # GET /api/v1/attempts
      def index
        attempts = current_user.quiz_attempts
                     .includes(:quiz)
                     .order(created_at: :desc)

        render json: {
          data: attempts.map { |a| attempt_json(a) },
          meta: { total: attempts.count }
        }
      end

      # GET /api/v1/attempts/:id
      def show
        render json: { data: attempt_json(@attempt, detail: true) }
      end

      # POST /api/v1/attempts
      # Body: { "quiz_id": 1 }
      def create
        quiz = Quiz.published.find(params[:quiz_id])

        existing = current_user.quiz_attempts
                     .where(quiz: quiz, status: :in_progress).first
        if existing
          render json: {
            data: attempt_json(existing),
            message: "Ya tienes un intento en progreso"
          }
          return
        end

        attempt = quiz.quiz_attempts.build(user: current_user)

        if attempt.save
          render json: { data: attempt_json(attempt) }, status: :created
        else
          render json: { errors: attempt.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/attempts/:id/submit
      def submit
        if @attempt.in_progress?
          @attempt.calculate_score!
          render json: {
            data: attempt_json(@attempt, detail: true),
            message: "Quiz completado. Puntaje: #{@attempt.score}/#{@attempt.total_questions}"
          }
        else
          render json: { error: "Este intento ya fue finalizado" }, status: :unprocessable_entity
        end
      end

      private

      def set_attempt
        @attempt = current_user.quiz_attempts.find(params[:id])
      end

      def attempt_json(attempt, detail: false)
        data = {
          id: attempt.id,
          quiz_id: attempt.quiz_id,
          quiz_title: attempt.quiz.title,
          status: attempt.status,
          score: attempt.score,
          total_questions: attempt.total_questions,
          percentage: attempt.completed? ? attempt.percentage : nil,
          completed_at: attempt.completed_at,
          created_at: attempt.created_at
        }

        if detail
          answers = attempt.attempt_answers.includes(question: :options, option: [])
          data[:answers] = answers.map do |a|
            answer_data = {
              question_id: a.question_id,
              question_body: a.question.body,
              selected_option_id: a.option_id,
              selected_option_body: a.option.body,
              correct: a.correct?
            }

            if attempt.completed?
              correct_opt = a.question.correct_option
              answer_data[:correct_option_id] = correct_opt&.id
              answer_data[:correct_option_body] = correct_opt&.body
            end

            answer_data
          end
        end

        data
      end
    end
  end
end
