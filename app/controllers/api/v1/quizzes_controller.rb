module Api
  module V1
    class QuizzesController < BaseController
      skip_before_action :authenticate_api_user!, only: [:index, :show]

      def index
        render json: { message: "TODO: implementar en Fase 6" }
      end

      def show
        render json: { message: "TODO: implementar en Fase 6" }
      end

      def create
        render json: { message: "TODO: implementar en Fase 6" }
      end

      def update
        render json: { message: "TODO: implementar en Fase 6" }
      end

      def destroy
        render json: { message: "TODO: implementar en Fase 6" }
      end

      def publish
        render json: { message: "TODO: implementar en Fase 6" }
      end
    end
  end
end
