Xray::Application.routes.draw do
  # get "public_pages/home"

  # get "public_pages/contact"

  # get "public_pages/about"

  root :to => 'public_pages#home'

  match '/home',       :to => 'public_pages#home'
  match '/help',    :to => redirect("http://mathias.lecuyer.me/xray/4-gmail-demo/")
  match '/contact',    :to => redirect("http://mathias.lecuyer.me/xray/6-team/")
  match '/about',      :to => redirect("http://mathias.lecuyer.me/xray/")
  match '/list_kw',    :to => 'pages#list_kw'
  match '/search_kw',  :to => 'pages#search_kw'
  match '/list_ads_by_kw',   :to => 'pages#list_ads_by_kw'
  match '/search_url', :to => 'pages#search_url'
  match '/info_ad',    :to => 'pages#info_ad'

  devise_for :users


  resources :public_pages
  resources :pages
  resources :ad

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
  match 'twilio/answer'       => 'twilio#answer_call'
  match 'twilio/token/:token' => 'twilio#prepare_token'

  resources :advertisements

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :snapshots
  match 'snapshots/context' => 'snapshots#create_with_context'
  resources :accounts
  resources :account_groups
  resources :truth
  get 'truth/data/:item', to: 'truth#data'
end
