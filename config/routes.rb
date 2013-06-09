SciGit::Application.routes.draw do
  get 'main/index' => 'main#index', :as => 'main_index'
  get 'main/home' => 'main#home', :as => 'main_home'

  devise_for :users, :controllers => { :registrations => 'users/registrations', :sessions => 'users/sessions' } do
    get :autocomplete_user_email, :to => 'users/registrations#autocomplete_user_email'
  end

  get 'users/:id' => 'users/registrations#show', :as => 'user'

  resources :projects do
    resources :project_changes, :path => 'changes', :as => 'changes' do
      collection do
        get 'page/:page', :action => 'list'
      end
      member do
        get 'diff'
        get 'file/*file', :action => 'file'
      end
    end

    resources :project_permissions, :path => 'permissions', :as => 'permissions'

    member do
      get 'subscribe'
      get 'doc/:doc_hash/*file', :action => 'doc'
    end

    collection do
      get 'public'
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
