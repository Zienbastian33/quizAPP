module Api
  module V1
    class QuizzesController < BaseController
      skip_before_action :authenticate_api_user!, only: [:index, :show]
      before_action :authenticate_api_user_if_present!, only: [:index, :show]
      before_action :set_quiz, only: [:show, :update, :destroy, :publish]

      # GET /api/v1/quizzes
      # Soporta paginación: ?page=1&limit=10
      def index
        if current_user&.admin?
          scope = current_user.quizzes.recent
        else
          scope = Quiz.published.recent
        end

        limit = (params[:limit] || 10).to_i.clamp(1, 50)
        @pagy, quizzes = pagy(:offset, scope, limit: limit)

        render json: {
          data: quizzes.map { |q| quiz_json(q) },
          meta: {
            total: @pagy.count,
            page: @pagy.page,
            pages: @pagy.last,
            limit: @pagy.limit[:limit]
          }
        }
      end

      # GET /api/v1/quizzes/:id
      def show
        authorize @quiz
        render json: { data: quiz_json(@quiz, detail: true) }
      end

      # POST /api/v1/quizzes
      def create
        quiz = current_user.quizzes.build(quiz_params)
        authorize quiz
        quiz.save!

        render json: { data: quiz_json(quiz) }, status: :created
      end

      # PATCH /api/v1/quizzes/:id
      def update
        authorize @quiz
        @quiz.update!(quiz_params)

        render json: { data: quiz_json(@quiz) }
      end

      # DELETE /api/v1/quizzes/:id
      def destroy
        authorize @quiz

        unless @quiz.draft?
          render json: { error: "No se puede eliminar un quiz publicado" }, status: :unprocessable_entity
          return
        end

        @quiz.destroy
        render json: { message: "Quiz eliminado exitosamente" }
      end

      # PATCH /api/v1/quizzes/:id/publish
      def publish
        authorize @quiz, :publish?

        if @quiz.publishable?
          @quiz.published!
          render json: { data: quiz_json(@quiz), message: "Quiz publicado exitosamente" }
        else
          messages = []
          messages << "Debe tener al menos 1 pregunta" if @quiz.questions.empty?
          @quiz.questions.each do |q|
            messages << "\"#{q.body.truncate(30)}\" necesita 4 opciones" if q.options.count != 4
            messages << "\"#{q.body.truncate(30)}\" necesita 1 respuesta correcta" if q.options.where(correct: true).count != 1
          end
          render json: { error: "No se puede publicar", details: messages }, status: :unprocessable_entity
        end
      end

      private

      def set_quiz
        if current_user&.admin?
          @quiz = Quiz.find(params[:id])
        else
          @quiz = Quiz.published.find(params[:id])
        end
      end

      def quiz_params
        params.permit(:title, :description)
      end

      def quiz_json(quiz, detail: false)
        data = {
          id: quiz.id,
          title: quiz.title,
          description: quiz.description,
          status: quiz.status,
          total_questions: quiz.questions.count,
          total_attempts: quiz.quiz_attempts.count,
          published_at: quiz.published_at,
          created_at: quiz.created_at,
          author: {
            id: quiz.user.id,
            name: quiz.user.name
          }
        }

        if detail
          data[:questions] = quiz.questions.includes(:options).ordered.map do |q|
            {
              id: q.id,
              body: q.body,
              position: q.position,
              options: q.options.map do |o|
                opt = { id: o.id, body: o.body }
                opt[:correct] = o.correct? if current_user&.admin? && quiz.user == current_user
                opt
              end
            }
          end
        end

        data
      end
    end
  end
end
