Rails.application.routes.draw do
  get 'home/index'
  root :to => "home#index"

  resources :users, only: :show do
    resources :posts, only: :show
  end

  resources :posts, except: :show
end
