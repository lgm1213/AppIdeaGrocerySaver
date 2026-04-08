Rails.application.routes.draw do
  # ── Health ────────────────────────────────────────────────────────────────
  get "up" => "rails/health#show", as: :rails_health_check

  # ── Public ────────────────────────────────────────────────────────────────
  root "pages#landing"

  # ── Auth — Rails native authentication ───────────────────────────────────
  resource  :session
  resources :passwords, param: :token

  # Registration (sign up)
  resource :registration, only: [ :new, :create ]

  # OmniAuth Google callback
  get  "/auth/:provider/callback", to: "omniauth_callbacks#create"
  post "/auth/:provider/callback", to: "omniauth_callbacks#create"
  get  "/auth/failure",            to: "omniauth_callbacks#failure"

  # ── Onboarding wizard ─────────────────────────────────────────────────────
  namespace :onboarding do
    get  :preferences,     to: "steps#preferences"
    post :preferences,     to: "steps#update_preferences"
    get  :budget_location, to: "steps#budget_location"
    post :budget_location, to: "steps#update_budget_location"
    get  :recap,           to: "steps#recap"
    post :complete,        to: "steps#complete"
    get  :success,         to: "steps#success"
  end

  # ── Admin ─────────────────────────────────────────────────────────────────
  namespace :admin do
    root to: "dashboard#index"
    resources :users, only: [ :index, :show ] do
      member do
        patch :toggle_admin
        patch :reset_onboarding
      end
    end
    resources :jobs, only: [ :index, :create ] do
      collection { get :status }
    end
    resources :job_executions, only: [ :index, :show, :destroy ] do
      member { post :retry }
    end
    resource  :system_health, only: [ :show ], controller: "system_health"
    resource  :email_settings, only: [ :show, :edit, :update ]
  end

  # ── Notifications ─────────────────────────────────────────────────────────
  patch "/notifications/dismiss_deals", to: "notifications#dismiss_deals",
                                        as: :dismiss_deals_notification

  # ── Authenticated app (/app scope) ────────────────────────────────────────
  scope "/app" do
    get "/", to: "dashboard#index", as: :dashboard

    # Meal plans
    resources :meal_plans do
      member do
        get  :calendar
        post :generate
        get  :recipe_picker
      end
      resources :meal_plan_entries, only: [ :create, :update, :destroy ] do
        member do
          patch :toggle_cooked
        end
      end
    end

    # Meal generator (singular — one flow per session)
    resource :meal_generator, only: [] do
      get  :new,     to: "meal_generators#new",      as: :new
      post :generate, to: "meal_generators#generate", as: :generate
      get  :results, to: "meal_generators#results",  as: :results
    end

    # Shopping lists
    resources :shopping_lists do
      member do
        patch :mark_complete
      end
      collection do
        post :generate_from_plan
      end
      resources :shopping_list_items, only: [ :create, :update, :destroy ] do
        member do
          patch :toggle
        end
      end
    end

    # Weekly deals
    resources :deals, only: [ :index, :show ] do
      collection do
        get :nearby
        get :matched
      end
    end

    # Weekly calendar
    resource :weekly_calendar, only: [ :show ] do
      get :week, on: :member
    end

    # Settings & preferences
    resource :settings,    only: [ :show, :edit, :update ]
    resource :preferences, only: [ :show, :edit, :update ]
  end
end
