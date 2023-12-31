Rails.application.routes.draw do
  root 'home#index'
  
  get 'signup', to: 'merchants#new'
  post 'signup', to: 'merchants#create'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resource :merchant, only: %i[show]
  resources :contracts, only: %i[new create]
  resources :account_transactions, only: %i[index]
  resources :wallet_transactions, only: %i[index]
  resources :withdrawal_transactions, only: %i[index]

  namespace :api do
    post 'withdraw/create', to: 'withdraws#create'
    post 'withdraw/confirm', to: 'withdraws#confirm'

    resources :withdrawal_requests, only: %i[show]
  end
end
