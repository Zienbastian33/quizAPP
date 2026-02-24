class QuestionPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    user&.admin?
  end

  def update?
    user&.admin? && record.quiz.user == user
  end

  def destroy?
    user&.admin? && record.quiz.user == user && record.quiz.draft?
  end
end
