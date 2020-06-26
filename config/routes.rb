Rails.application.routes.draw do
  get 'comment/create'
  get 'comment/update'
  get 'comment/destroy'
  get "reaction/create"
  get "reaction/destroy"
  get "search", to: "search#index"
  get "timeline", to: "timeline#index"
  root to: "home#index"

  get "home/index"

  resources :users, only: [:show, :edit, :update] do
    resources :posts, only: :show
  end

  resources :posts, except: :show
  resources :comments, except: [:show, :new]
  resources :invites, except: [:show]
  resources :post_images, only: [:create, :destroy]
  resources :user_profile_images, only: [:create, :destroy]
  resources :reactions, only: [:create, :destroy]
end
