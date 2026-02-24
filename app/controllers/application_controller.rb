class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Method

  # Permitir parámetros adicionales en Devise (name)
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def user_not_authorized
    flash[:alert] = "No tienes permiso para realizar esta acción."
    redirect_back(fallback_location: root_path)
  end
end
