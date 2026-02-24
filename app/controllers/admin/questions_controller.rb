module Admin
  class QuestionsController < Admin::BaseController
    before_action :set_quiz
    before_action :set_question, only: [:show, :edit, :update, :destroy]
    before_action :process_correct_option, only: [:create, :update]

    # GET /admin/quizzes/:quiz_id/questions/new
    def new
      @question = @quiz.questions.build
      # Pre-construir 4 opciones vacías para el formulario
      4.times { @question.options.build }
    end

    # POST /admin/quizzes/:quiz_id/questions
    def create
      @question = @quiz.questions.build(question_params)
      @question.position = @quiz.questions.count + 1

      if @question.save
        redirect_to admin_quiz_path(@quiz), notice: "Pregunta agregada exitosamente."
      else
        # Rellenar opciones faltantes si el formulario falla
        remaining = 4 - @question.options.reject(&:marked_for_destruction?).size
        remaining.times { @question.options.build } if remaining > 0
        render :new, status: :unprocessable_entity
      end
    end

    # GET /admin/quizzes/:quiz_id/questions/:id
    def show
    end

    # GET /admin/quizzes/:quiz_id/questions/:id/edit
    def edit
      # Rellenar opciones faltantes hasta 4
      remaining = 4 - @question.options.size
      remaining.times { @question.options.build } if remaining > 0
    end

    # PATCH /admin/quizzes/:quiz_id/questions/:id
    def update
      if @question.update(question_params)
        redirect_to admin_quiz_path(@quiz), notice: "Pregunta actualizada exitosamente."
      else
        remaining = 4 - @question.options.reject(&:marked_for_destruction?).size
        remaining.times { @question.options.build } if remaining > 0
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /admin/quizzes/:quiz_id/questions/:id
    def destroy
      @question.destroy
      redirect_to admin_quiz_path(@quiz), notice: "Pregunta eliminada."
    end

    private

    def set_quiz
      @quiz = current_user.quizzes.find(params[:quiz_id])
    end

    def set_question
      @question = @quiz.questions.find(params[:id])
    end

    def question_params
      params.require(:question).permit(
        :body, :position, :image, :media,
        options_attributes: [:id, :body, :correct, :_destroy]
      )
    end

    def process_correct_option
      correct_index = params.dig(:question, :options_attributes, :correct_option)
      return unless correct_index.present?

      if params[:question][:options_attributes].is_a?(Hash)
        params[:question][:options_attributes].each do |key, attrs|
          next if key == "correct_option"
          attrs[:correct] = (key.to_s == correct_index.to_s) ? "1" : "0"
        end
      end

      # Eliminar el campo correct_option que no es un atributo real
      params[:question][:options_attributes].delete(:correct_option)
    end
  end
end
