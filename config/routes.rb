Rails.application.routes.draw do
  root 'dashboard#index'

  get 'telemetries/fetch', to: 'telemetries#fetch'
  get 'telemetries/poll', to: 'telemetries#poll'

  resources :telemetries, only: [] do
    collection do
      get 'battery'
      get 'solar'
    end
  end
end
