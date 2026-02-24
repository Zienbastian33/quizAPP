module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_api_user!

      # ── Manejo global de errores ──
      rescue_from ActiveRecord::RecordNotFound do |_error|
        render json: { error: "Recurso no encontrado" }, status: :not_found
      end

      rescue_from Pundit::NotAuthorizedError do |_error|
        render json: { error: "No autorizado para realizar esta acción" }, status: :forbidden
      end

      rescue_from ActiveRecord::RecordInvalid do |error|
        render json: { errors: error.record.errors.full_messages }, status: :unprocessable_entity
      end

      private

      # Autenticación por token
      # El cliente envía: Authorization: Bearer <token>
      def authenticate_api_user!
        token = request.headers["Authorization"]&.split(" ")&.last
        @current_api_user = User.find_by(api_token: token)

        unless @current_api_user
          render json: { error: "Token inválido o ausente. Envía el header: Authorization: Bearer <tu_token>" }, status: :unauthorized
        end
      end

      # Método para acceder al usuario actual en la API
      def current_user
        @current_api_user
      end
    end
  end
end
