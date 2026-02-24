Rails.application.routes.draw do
  # ══════════════════════════════════════════════
  # DEVISE — Autenticación
  # ══════════════════════════════════════════════
  devise_for :users

  # ══════════════════════════════════════════════
  # RAÍZ — Página principal
  # ══════════════════════════════════════════════
  root "home#index"

  # ══════════════════════════════════════════════
  # RUTAS PÚBLICAS — Cualquier persona (player o visitante)
  # ══════════════════════════════════════════════

  # Ver quizzes publicados y responderlos
  resources :quizzes, only: [:index, :show] do
    # Intentos de quiz (player)
    resources :attempts, only: [:create, :show] do
      member do
        post :submit    # POST /quizzes/:quiz_id/attempts/:id/submit → finalizar intento
      end
      # Respuestas individuales dentro de un intento
      resources :answers, only: [:create]
    end
  end

  # ══════════════════════════════════════════════
  # ADMIN — Panel de administración
  # ══════════════════════════════════════════════
  # Todas las rutas bajo /admin/...
  # Solo accesibles por usuarios con rol admin

  namespace :admin do
    root "dashboard#index"    # GET /admin → Admin::DashboardController#index

    resources :quizzes do     # CRUD completo de quizzes
      member do
        patch :publish        # PATCH /admin/quizzes/:id/publish → publicar
      end

      # Preguntas anidadas dentro de un quiz
      resources :questions, except: [:index] do
        # No necesitamos index porque las preguntas se ven en el show del quiz
      end
    end
  end

  # ══════════════════════════════════════════════
  # API JSON — Endpoints para consumo externo
  # ══════════════════════════════════════════════
  # Todas las rutas bajo /api/v1/...
  # Autenticación por token en header Authorization

  namespace :api do
    namespace :v1 do
      # Auth
      post "login", to: "auth#login"

      # Quizzes (CRUD + publicar)
      resources :quizzes, only: [:index, :show, :create, :update, :destroy] do
        member do
          patch :publish
        end
        # Preguntas anidadas
        resources :questions, only: [:index, :show, :create, :update, :destroy]
      end

      # Intentos (player)
      resources :attempts, only: [:index, :show, :create] do
        member do
          post :submit
        end
        # Respuestas
        resources :answers, only: [:create]
      end
    end
  end

  # ══════════════════════════════════════════════
  # HEALTH CHECK — Para verificar que el servidor está vivo
  # ══════════════════════════════════════════════
  get "up" => "rails/health#show", as: :rails_health_check
end
