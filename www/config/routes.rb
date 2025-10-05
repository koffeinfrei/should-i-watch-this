Rails.application.routes.draw do
  passwordless_for :users, controller: "sessions"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "home#show"

  resource :search, only: :new, controller: "search" do
    get :autocomplete, on: :collection
  end

  resources :watchlist_items, only: [] do
    post :toggle, on: :collection
  end
  get "watchlist", to: "watchlist#show", as: :watchlist
  scope "watchlist", as: :watchlist do
    resource :import, only: [:new, :create], controller: "watchlist_import"
  end

  get ":wiki_id(/:title)(/:year)", to: "movies#show", as: :movie, constraints: { wiki_id: /Q\d+/ }
  get ":title/:year", to: "movies#legacy", as: :legacy_movie
  post ":wiki_id(/:title)(/:year)", to: "movies#fetch", as: :fetch_movie

  get "error", to: "error#show"
  get "not_found", to: "error#not_found", as: :not_found

  get "*", via: :all, to: "error#not_found"
end
