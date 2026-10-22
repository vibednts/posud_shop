Rails.application.routes.draw do
  devise_for :users
  root "home#index"
resources :products, only: %i[index show] do
  resources :reviews, only: %i[create destroy]
end
  resource :cart, only: :show
  resources :cart_items, only: %i[create update destroy]
  resources :orders, only: %i[index new create show]
  
   get  "contacts", to: "contact_messages#new",    as: :contacts
   post "contacts", to: "contact_messages#create"
   namespace :admin do
  root "dashboard#index"
  resources :products, except: :show
  resources :categories, except: :show
  resources :orders, only: %i[index show update]
  resources :contact_messages, only: %i[index show destroy]
end
  resources :orders, only: %i[index new create show] do
  resource :payment, only: %i[new create]
end
   match "*path", to: "errors#not_found", via: :all,
      constraints: ->(req) { !req.path.start_with?("/rails/") }
end

