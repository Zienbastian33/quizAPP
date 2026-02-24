class User < ApplicationRecord
  # ── Devise ──
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ── Roles ──
  # player = 0 (default), admin = 1
  enum :role, { player: 0, admin: 1 }, default: :player

  # ── Token para API ──
  has_secure_token :api_token

  # ── Relaciones ──
  has_many :quizzes, dependent: :destroy           # quizzes creados (admin)
  has_many :quiz_attempts, dependent: :destroy      # intentos realizados (player)

  # ── Validaciones ──
  validates :name, presence: true
  validates :role, presence: true
end
