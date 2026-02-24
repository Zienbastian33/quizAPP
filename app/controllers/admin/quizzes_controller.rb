module Admin
  class QuizzesController < Admin::BaseController
    before_action :set_quiz, only: [:show, :edit, :update, :destroy, :publish]

    # GET /admin/quizzes
    def index
      @quizzes = current_user.quizzes.recent
    end

    # GET /admin/quizzes/:id
    def show
      @questions = @quiz.questions.includes(:options).ordered
    end

    # GET /admin/quizzes/new
    def new
      @quiz = Quiz.new
    end

    # POST /admin/quizzes
    def create
      @quiz = current_user.quizzes.build(quiz_params)

      if @quiz.save
        redirect_to admin_quiz_path(@quiz), notice: "Quiz creado exitosamente como borrador."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # GET /admin/quizzes/:id/edit
    def edit
    end

    # PATCH /admin/quizzes/:id
    def update
      if @quiz.update(quiz_params)
        redirect_to admin_quiz_path(@quiz), notice: "Quiz actualizado exitosamente."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/quizzes/:id
    def destroy
      if @quiz.draft?
        @quiz.destroy
        redirect_to admin_quizzes_path, notice: "Quiz eliminado."
      else
        redirect_to admin_quiz_path(@quiz), alert: "No se puede eliminar un quiz publicado."
      end
    end

    # PATCH /admin/quizzes/:id/publish
    def publish
      if @quiz.publishable?
        @quiz.published!
        redirect_to admin_quiz_path(@quiz), notice: "¡Quiz publicado exitosamente!"
      else
        messages = []
        messages << "Debe tener al menos 1 pregunta" if @quiz.questions.empty?
        @quiz.questions.each do |q|
          messages << "\"#{q.body.truncate(30)}\" necesita exactamente 4 opciones" if q.options.count != 4
          messages << "\"#{q.body.truncate(30)}\" necesita exactamente 1 respuesta correcta" if q.options.where(correct: true).count != 1
        end
        redirect_to admin_quiz_path(@quiz), alert: "No se puede publicar: #{messages.join('. ')}."
      end
    end

    private

    def set_quiz
      @quiz = current_user.quizzes.find(params[:id])
    end

    def quiz_params
      params.require(:quiz).permit(:title, :description, :cover_image, :media)
    end
  end
end
