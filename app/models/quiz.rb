class Quiz < ApplicationRecord
  # ── Relaciones ──
  belongs_to :user
  has_many :questions, -> { order(:position) }, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy

  # ── Active Storage (imágenes/videos) ──
  has_one_attached :cover_image
  has_one_attached :media

  # ── Estados ──
  enum :status, { draft: 0, published: 1 }, default: :draft

  # ── Validaciones ──
  validates :title, presence: true
  validates :description, presence: true

  # ── Scopes ──
  scope :published, -> { where(status: :published) }
  scope :drafts, -> { where(status: :draft) }
  scope :recent, -> { order(created_at: :desc) }

  # ── Callbacks ──
  before_save :set_published_at, if: :will_save_change_to_status?

  # ── Métodos de negocio ──

  # ¿Se puede publicar este quiz?
  # Requiere: estar en draft + tener al menos 1 pregunta + cada pregunta con 4 opciones y 1 correcta
  def publishable?
    draft? && questions.any? && questions.all? do |q|
      q.options.count == 4 && q.options.where(correct: true).count == 1
    end
  end

  def total_questions
    questions.count
  end

  private

  def set_published_at
    self.published_at = Time.current if published?
  end
end
