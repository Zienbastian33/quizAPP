class QuizAttempt < ApplicationRecord
  # ── Relaciones ──
  belongs_to :user
  belongs_to :quiz
  has_many :attempt_answers, dependent: :destroy

  # ── Estados ──
  enum :status, { in_progress: 0, completed: 1 }, default: :in_progress

  # ── Validaciones ──
  validates :user_id, presence: true
  validates :quiz_id, presence: true

  # REGLA DE NEGOCIO: No se puede intentar un quiz en draft
  validate :quiz_must_be_published, on: :create

  # REGLA DE NEGOCIO: No se puede modificar un intento completado
  validate :cannot_modify_if_completed, on: :update

  # ── Scopes ──
  scope :completed, -> { where(status: :completed) }
  scope :in_progress, -> { where(status: :in_progress) }
  scope :recent, -> { order(created_at: :desc) }

  # ── Métodos de negocio ──

  # Calcula el puntaje y finaliza el intento
  def calculate_score!
    correct_count = attempt_answers.where(correct: true).count
    total = quiz.questions.count

    update!(
      score: correct_count,
      total_questions: total,
      status: :completed,
      completed_at: Time.current
    )
  end

  # Porcentaje de respuestas correctas
  def percentage
    return 0 if total_questions.zero?
    ((score.to_f / total_questions) * 100).round(1)
  end

  private

  def quiz_must_be_published
    if quiz&.draft?
      errors.add(:quiz, "debe estar publicado para poder responderlo")
    end
  end

  def cannot_modify_if_completed
    if status_was == "completed"
      errors.add(:base, "No se puede modificar un intento finalizado")
    end
  end
end
