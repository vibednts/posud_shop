Rails.application.routes.draw do
  devise_for :users
  root "home#index"
  resources :products, only: %i[index show]
  resource :cart, only: :show
  resources :cart_items, only: %i[create update destroy]
end
