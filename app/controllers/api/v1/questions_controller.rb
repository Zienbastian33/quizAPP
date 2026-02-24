module Api
  module V1
    class QuestionsController < BaseController
      before_action :set_quiz
      before_action :set_question, only: [:show, :update, :destroy]

      # GET /api/v1/quizzes/:quiz_id/questions
      def index
        questions = @quiz.questions.includes(:options).ordered

        render json: {
          data: questions.map { |q| question_json(q) },
          meta: { total: questions.count, quiz_id: @quiz.id }
        }
      end

      # GET /api/v1/quizzes/:quiz_id/questions/:id
      def show
        render json: { data: question_json(@question) }
      end

      # POST /api/v1/quizzes/:quiz_id/questions
      def create
        authorize_quiz_admin!
        return if performed?

        question = @quiz.questions.build(question_params)
        question.position = @quiz.questions.count + 1

        if question.save
          render json: { data: question_json(question) }, status: :created
        else
          render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/quizzes/:quiz_id/questions/:id
      def update
        authorize_quiz_admin!
        return if performed?

        if @question.update(question_params)
          render json: { data: question_json(@question) }
        else
          render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/quizzes/:quiz_id/questions/:id
      def destroy
        authorize_quiz_admin!
        return if performed?

        unless @quiz.draft?
          render json: { error: "No se pueden eliminar preguntas de un quiz publicado" }, status: :unprocessable_entity
          return
        end

        @question.destroy
        render json: { message: "Pregunta eliminada exitosamente" }
      end

      private

      def set_quiz
        @quiz = Quiz.find(params[:quiz_id])
      end

      def set_question
        @question = @quiz.questions.find(params[:id])
      end

      def question_params
        params.permit(:body, :position, options_attributes: [:id, :body, :correct, :_destroy])
      end

      def authorize_quiz_admin!
        unless current_user&.admin? && @quiz.user == current_user
          render json: { error: "No tienes permiso para modificar este quiz" }, status: :forbidden
          return
        end
      end

      def question_json(question)
        {
          id: question.id,
          body: question.body,
          position: question.position,
          quiz_id: question.quiz_id,
          options: question.options.map do |o|
            opt = { id: o.id, body: o.body }
            opt[:correct] = o.correct? if current_user&.admin? && @quiz.user == current_user
            opt
          end
        }
      end
    end
  end
end
