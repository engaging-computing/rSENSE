Rsense::Application.routes.draw do
  resources :media_objects

  post "projects/:id/templateFields" => "projects#templateFields"

  get "project_templates/index"

  match "/projects/import" => "projects#importFromIsense"
  match "/projects/import/:pid" => "projects#importFromIsense"


  resources :visualizations

  #resources :data_sets

  resources :memberships

  resources :groups

  resources :fields

  match "projects/create" => "projects#create"
  resources :projects

  match "tutorials/create" => "tutorials#create"
  match "/tutorials/switch/" => "tutorials#switch"
  resources :tutorials

  get "home/index"
  root :to => "home#index"

  get "admin/index"

  get 'admin' => 'admin#index'

  resources :data_sets do
    get 'getData' => :getData
  end

  #Routes for project templates
  match "/project_templates" => "project_templates#index"

  #Routes for uploading data
  match "/projects/:id/uploadCSV" => "data_sets#uploadCSV"
  match "/data_sets/:pid/manualEntry" => "data_sets#manualEntry"
  match "/data_sets/:pid/manualUpload" => "data_sets#manualUpload"
  match "/data_sets/:id/editTable" => "data_sets#editTable"

  match "/projects/:id/export/data_sets/*datasets" => "data_sets#export"
  match "/projects/:id/export" => "data_sets#export"

  #Routes for displaying data
  match "/projects/:id/data_sets/*datasets" => "visualizations#displayVis"
  match "/projects/:id/data_sets/" => "visualizations#displayVis"
  match "/visualizations/:id/embeded" => "visualizations#embedVis"




  match "/projects/:id/removeField" => "projects#removeField"

  match "/data_sets/:id/postCSV" => "data_sets#uploadCSV"
  match "/media_objects/saveMedia/*keys" => "media_objects#saveMedia"

  controller :sessions do
    post 'login' => :create
    delete 'login' => :destroy
  end

  match "/users/verify" => "users#verify"
  resources :users
  match "/users/validate/:key" => "users#validate"
  match "/users/:id/contributions" => "users#contributions"

  match "/projects/:id/updateLikedStatus" => "projects#updateLikedStatus"



  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

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
end
