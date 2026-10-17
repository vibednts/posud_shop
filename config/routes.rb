Rails.application.routes.draw do
  devise_for :users
  root "home#index"
  resources :products, only: %i[index show]
end
