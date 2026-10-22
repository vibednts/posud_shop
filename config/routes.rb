Rails.application.routes.draw do
  devise_for :users
  root "home#index"
resources :products, only: %i[index show] do
  resources :reviews, only: %i[create destroy]
end
  resource :cart, only: :show
  resources :cart_items, only: %i[create update destroy]
  resources :orders, only: %i[index new create show]
end
