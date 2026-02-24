class QuizPolicy < ApplicationPolicy
  # ── Acciones públicas ──

  # Listar quizzes: todos pueden ver el listado
  def index?
    true
  end

  # Ver un quiz individual
  def show?
    if record.published?
      true                          # Publicados: cualquiera puede ver
    else
      user&.admin?                  # Borradores: solo admin
    end
  end

  # ── Acciones de admin ──

  def create?
    user&.admin?
  end

  def update?
    user&.admin? && record.user == user
  end

  def destroy?
    user&.admin? && record.user == user && record.draft?
  end

  # Publicar un quiz
  def publish?
    user&.admin? && record.user == user && record.publishable?
  end

  # ── Scope: qué registros puede ver cada rol ──
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all                   # Admin ve todos (draft + published)
      else
        scope.published             # Player/visitante ve solo publicados
      end
    end
  end
end
