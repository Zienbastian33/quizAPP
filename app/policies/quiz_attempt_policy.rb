class QuizAttemptPolicy < ApplicationPolicy
  # Crear un intento: solo players logueados, solo quizzes publicados
  def create?
    user&.player? && record.quiz.published?
  end

  # Ver un intento: el dueño del intento o cualquier admin
  def show?
    record.user == user || user&.admin?
  end

  # Finalizar (submit) un intento: solo el dueño y solo si está en progreso
  def submit?
    record.user == user && record.in_progress?
  end
end
