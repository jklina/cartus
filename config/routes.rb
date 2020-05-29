Rails.application.routes.draw do
  get "home/index"
  root to: "home#index"

  resources :users, only: [:show, :edit, :update] do
    resources :posts, only: :show
  end

  resources :posts, except: :show
  resources :images, only: [:create, :destroy]
end
