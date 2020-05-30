Rails.application.routes.draw do
  get "home/index"
  root to: "home#index"

  resources :users, only: [:show, :edit, :update] do
    resources :posts, only: :show
  end

  resources :posts, except: :show
  resources :post_images, only: [:create, :destroy]
  resources :user_profile_images, only: [:create, :destroy]
end
