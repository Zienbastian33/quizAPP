class AttemptAnswer < ApplicationRecord
  # ── Relaciones ──
  belongs_to :quiz_attempt
  belongs_to :question
  belongs_to :option

  # ── Callbacks ──
  # Marcar automáticamente si la respuesta es correcta
  before_save :set_correctness

  # ── Validaciones ──
  # Un player no puede responder la misma pregunta dos veces en un intento
  validates :question_id, uniqueness: {
    scope: :quiz_attempt_id,
    message: "ya fue respondida en este intento"
  }

  # No se puede agregar respuestas a un intento completado
  validate :attempt_must_be_in_progress, on: :create

  private

  def set_correctness
    self.correct = option.correct?
  end

  def attempt_must_be_in_progress
    if quiz_attempt&.completed?
      errors.add(:base, "No se pueden agregar respuestas a un intento finalizado")
    end
  end
end
