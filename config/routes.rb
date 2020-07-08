Rails.application.routes.draw do
  # Clearance
  resources :passwords, controller: "clearance/passwords", only: [:create, :new]
  resource :session, controller: "clearance/sessions", only: [:create]
  resources :users, only: [:create] do
    resource :password,
      controller: "clearance/passwords",
      only: [:edit, :update]
  end
  get "/sign_in" => "clearance/sessions#new", :as => "sign_in"
  delete "/sign_out" => "clearance/sessions#destroy", :as => "sign_out"
  get "/sign_up" => "clearance/users#new", :as => "sign_up"
  get "/confirm_email/:token" => "email_confirmations#update", :as => "confirm_email"

  get "search", to: "search#index"
  get "timeline", to: "timeline#index"
  get "notifications", to: "notifications#index"
  root to: "home#index"

  get "home/index"

  resources :users, only: [:show, :edit, :update] do
    resources :friends_posts, only: [:new, :create]
  end
  resources :posts
  resources :comments, except: [:show, :new]
  resources :invites, except: [:show]
  resources :post_images, only: [:create, :destroy]
  resources :user_profile_images, only: [:create, :destroy]
  resources :reactions, only: [:create, :destroy]
end
