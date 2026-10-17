Rails.application.routes.draw do
  root "home#index"
  resources :products, only: %i[index show]
end
