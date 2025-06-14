Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "home#show"

  resource :search, only: [:new, :create], controller: "search" do
    get :autocomplete, on: :collection
  end
  get ":wiki_id(/:title)(/:year)", to: "movies#show", as: :movie, constraints: { wiki_id: /Q\d+/ }
  get ":title/:year", to: "movies#legacy", as: :legacy_movie
  post ":wiki_id(/:title)(/:year)", to: "movies#fetch", as: :fetch_movie

  get "error", to: "error#show"

  get "*", via: :all, to: "error#not_found"
end
