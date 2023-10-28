Rails.application.routes.draw do
  root 'home#index'
  
  get 'signup', to: 'merchants#new'
  post 'signup', to: 'merchants#create'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resource :merchant, only: %i[show]
  resource :wallet, only: %i[show new create]
  resource :account, only: %i[show new create]
  resources :contracts, only: %i[new create]
  resources :stable_coins, only: %i[new create]

  post 'withdraw/create', to: 'withdraws#create'
  post 'withdraw/confirm', to: 'withdraws#confirm'
end
