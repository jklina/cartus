Rails.application.routes.draw do
  get "search", to: "search#index"
  get "timeline", to: "timeline#index"
  root to: "home#index"

  get "home/index"

  resources :users, only: [:show, :edit, :update] do
    resources :posts, only: :show
  end

  resources :posts, except: :show
  resources :invites, except: [:show]
  resources :post_images, only: [:create, :destroy]
  resources :user_profile_images, only: [:create, :destroy]
end
