class Question < ApplicationRecord
  # ── Relaciones ──
  belongs_to :quiz
  has_many :options, -> { order(:id) }, dependent: :destroy
  has_many :attempt_answers, dependent: :destroy

  # ── Active Storage ──
  has_one_attached :image
  has_one_attached :media

  # ── Nested Attributes ──
  # Permite crear/editar opciones DESDE el formulario de la pregunta
  accepts_nested_attributes_for :options,
    reject_if: :all_blank,
    allow_destroy: true

  # ── Validaciones ──
  validates :body, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # ── Scopes ──
  scope :ordered, -> { order(:position) }

  # ── Métodos ──
  def correct_option
    options.find_by(correct: true)
  end
end
