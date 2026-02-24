class Option < ApplicationRecord
  # ── Relaciones ──
  belongs_to :question

  # ── Validaciones ──
  validates :body, presence: true
  validates :correct, inclusion: { in: [true, false] }
end
