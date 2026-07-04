Rails.application.routes.draw do
  root 'dashboard#index'

  # APIs
  get 'telemetries/fetch', to: 'telemetries#fetch'
  get 'telemetries/poll', to: 'telemetries#poll'
  get 'weather', to: 'weather#index'

  resources :telemetries, only: [] do
    collection do
      get 'battery'
      get 'solar'
    end
  end
end
