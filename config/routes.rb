LawDoc::Application.routes.draw do
  get 'main/index' => 'main#index', :as => 'main_index'
  get 'main/home' => 'main#home', :as => 'main_home'
  # We have to break the "user" as opposed to "view_user" convention here because of some
  # error we get in the registration process when in sign_up.
  get 'users/:id' => 'users/registrations#show', :as => 'view_user'

  devise_for :users,
             :controllers => {
    :registrations => 'users/registrations',
    :sessions => 'users/sessions',
  }

  resources :project_permissions

  resources :project_changes

  resources :projects do
    member do
      get 'subscribe'
    end

    collection do
      get 'company'
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'main#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
