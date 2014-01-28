Rsense::Application.routes.draw do
  # See how all your routes lay out with "rake routes"
  mount Ckeditor::Engine => '/ckeditor'

  post "/data_sets/dataFileUpload", to: "data_sets#dataFileUpload"
  put "/data_sets/field_matching", to: "data_sets#field_matching"

  get '/news/add', to: 'news#create'
  resources :news, except: [:new, :edit]

  resources :media_objects

  get  "/projects/:id/edit_fields" => "projects#edit_fields"
  post "/projects/:id/save_fields" => "projects#save_fields"

  post "projects/:id/templateFields" => "projects#templateFields"
  post "/projects/import" => "projects#importFromIsense"
  post "/projects/import/:pid" => "projects#importFromIsense"

  resources :visualizations, except: [:new]

  resources :data_sets  

  resources :fields, except: [:index, :new, :edit]

  get "projects/create" => "projects#create"
  resources :projects, except: [:new]

  #match "tutorials/create" => "tutorials#create"
  post "/tutorials/switch/" => "tutorials#switch"
  resources :tutorials, except: [:new]

  get 'about' => 'home#about'
  get 'contact' => 'home#contact'
  
  get "home/index"
  root :to => "home#index"

  get "admin/index"

  get 'admin' => 'admin#index'

  resources :data_sets do
    get 'getData' => :getData
  end

  #Routes for uploading data
  get "/projects/:id/manualEntry" => "data_sets#manualEntry"
  post "/projects/:id/jsonDataUpload" => "data_sets#jsonDataUpload"
  get "/projects/:id/export/data_sets/*datasets" => "data_sets#export"
  get "/projects/:id/export" => "data_sets#export"

  get "/data_sets/:id/edit" => "data_sets#edit"
  put "/data_sets/:id/edit" => "data_sets#edit"
  post "/data_sets/:id/edit" => "data_sets#edit"

  #Routes for displaying data
  get "/projects/:id/data_sets/*datasets" => "visualizations#displayVis"
  get "/projects/:id/data_sets/" => "visualizations#displayVis"

  post "/projects/:id/removeField" => "projects#removeField"

  post "/media_objects/saveMedia/*keys" => "media_objects#saveMedia"
  get "/projects/:id/data_sets/*datasets" => "visualizations#displayVis"
  get "/projects/:id/data_sets/" => "visualizations#displayVis"
  post "/projects/:id/templateUpload", to: "projects#templateUpload"
  post "/projects/:id/finishTemplateUpload", to: "projects#finishTemplateUpload"
  put "/projects/:id/removeField" => "projects#removeField"
  
  post "/media_objects/saveMedia/*keys" => "media_objects#saveMedia"

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'login' => :destroy
  end
  get '/sessions/verify' => 'sessions#verify'

  get "/users/pw_request" => "users#pw_request"
  post "/users/pw_send_key" => "users#pw_send_key"
  get "/users/pw_reset/:key" => "users#pw_reset"
  resources :users
  get "/users/validate/:key" => "users#validate"
  get "/users/:id/contributions" => "users#contributions"

  post "/projects/:id/updateLikedStatus" => "projects#updateLikedStatus"

  post "/projects/:id/updateFields" => "fields#updateFields"

  resources :contrib_keys, only: [:create, :destroy]
  post "/contrib_keys/enter" => 'contrib_keys#enter'

  get "/api/v1/docs" => "home#api_v1"
  #API routes
  scope :api, defaults: {:format => 'json'}, except: :destroy do
    scope :v1 do
      resources :projects
      resources :fields
      resources :users
      resources :media_objects
      resources :visualizations
      post 'login' => "sessions#create"
    end
  end
end
