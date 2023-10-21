Rails.application.routes.draw do
  root 'home#index'
  
  get 'signup', to: 'merchants#new'
  post 'signup', to: 'merchants#create'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

end
