module Api
  module V1
    class AuthController < ActionController::API
      # POST /api/v1/login
      # Body: { email: "...", password: "..." }
      # Response: { token: "...", user: { id, email, name, role } }
      def login
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          render json: {
            token: user.api_token,
            user: {
              id: user.id,
              email: user.email,
              name: user.name,
              role: user.role
            }
          }, status: :ok
        else
          render json: {
            error: "Credenciales inválidas"
          }, status: :unauthorized
        end
      end
    end
  end
end
