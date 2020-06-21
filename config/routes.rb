Rails.application.routes.draw do
  get "timeline", to: "timeline#index"
  root to: "timeline#index"

  get "home/index"

  resources :users, only: [:show, :edit, :update] do
    resources :posts, only: :show
  end

  resources :posts, except: :show
  resources :relationships, only: [:create]
  resources :post_images, only: [:create, :destroy]
  resources :user_profile_images, only: [:create, :destroy]
end
