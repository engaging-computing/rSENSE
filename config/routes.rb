Rsense::Application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations', passwords: 'passwords', confirmations: 'confirmations' }

  get '/users/:id/contributions' => 'users#contributions'
  get '/users/:id/edit' => 'users#edit'

  get 'users/password/edit:key' => 'users#pw_reset'

  get '/users/pw_request' => 'users#pw_request'
  post '/users/pw_send_key' => 'users#pw_send_key'
  resources :users

  get 'testing/index'

  # See how all your routes lay out with "rake routes"
  post '/data_sets/dataFileUpload', to: 'data_sets#dataFileUpload'
  put '/data_sets/field_matching', to: 'data_sets#field_matching'

  get '/news/add', to: 'news#create'
  resources :news, except: [:new, :edit]

  resources :media_objects

  get '/projects/:id/edit_fields' => 'projects#edit_fields'
  post '/projects/:id/save_fields' => 'projects#save_fields'

  get '/projects/:id/edit_formula_fields' => 'projects#edit_formula_fields'
  post '/projects/:id/save_formula_fields' => 'projects#save_formula_fields'

  post 'projects/:id/templateFields' => 'projects#templateFields'
  post '/projects/import' => 'projects#importFromIsense'
  post '/projects/import/:pid' => 'projects#importFromIsense'

  post '/projects/create_tag' => 'projects#create_tag'
  delete '/projects/remove_tag' => 'projects#remove_tag'

  resources :visualizations, except: [:new]

  resources :data_sets

  delete '/delete_data_sets/:id_list' => 'data_sets#deleteMultiple'

  resources :fields, except: [:index, :new, :edit]
  resources :formula_fields, except: [:index, :new, :edit]

  get 'projects/create' => 'projects#create'
  post 'projects/create' => 'projects#create'
  resources :projects, except: [:new]

  # match "tutorials/create" => "tutorials#create"
  post '/tutorials/switch/' => 'tutorials#switch'
  resources :tutorials, except: [:new]
  put '/tutorials/:id/edit' => 'tutorials#update'

  get 'about' => 'home#about'
  get 'contact' => 'home#contact'
  get 'report_bug' => 'home#report_bug'
  get 'privacy_policy' => 'home#privacy_policy'

  get 'home/index'
  root to: 'home#index'

  get 'admin/index'

  get 'admin' => 'admin#index'

  resources :data_sets do
    get 'getData' => :getData
  end

  get '/projects/:id/clone' => 'projects#clone'

  # Routes for uploading data
  get '/projects/:id/manualEntry' => 'data_sets#manualEntry'
  post '/projects/:id/jsonDataUpload' => 'data_sets#jsonDataUpload'
  get '/projects/:id/export/data_sets/*datasets' => 'data_sets#export'
  get '/projects/:id/export_concatenated/data_sets/*datasets' => 'data_sets#export_concatenated'
  get '/projects/:id/export' => 'data_sets#export'

  get '/data_sets/:id/edit' => 'data_sets#edit'
  put '/data_sets/:id/edit' => 'data_sets#edit'
  post '/data_sets/:id/edit' => 'data_sets#edit'

  # Routes for displaying data
  get '/projects/:id/data_sets/*datasets' => 'visualizations#displayVis'
  get '/projects/:id/data_sets/' => 'visualizations#displayVis'

  post '/projects/:id/removeField' => 'projects#removeField'

  post '/media_objects/saveMedia/*keys' => 'media_objects#saveMedia'
  get '/projects/:id/data_sets/*datasets' => 'visualizations#displayVis'
  get '/projects/:id/data_sets/' => 'visualizations#displayVis'
  post '/projects/:id/templateUpload', to: 'projects#templateUpload'
  post '/projects/:id/finishTemplateUpload', to: 'projects#finishTemplateUpload'
  put '/projects/:id/removeField' => 'projects#removeField'

  get '/sessions/permissions' => 'sessions#permissions'

  post '/projects/:id/updateLikedStatus' => 'projects#updateLikedStatus'

  post '/projects/:id/updateFields' => 'fields#updateFields'

  resources :contrib_keys, only: [:create, :destroy]
  post '/contrib_keys/enter' => 'contrib_keys#enter'
  get '/contrib_keys/clear' => 'contrib_keys#clear'

  get '/api/v1/docs' => 'home#api_v1'
  get '/api/formulas_help' => 'home#formulas_help'

  # Github Authentication Routes
  get '/auth/github' => 'sessions#github_authorize'
  get '/auth/anon_github' => 'application#create_issue_anon'
  get '/auth/github/callback' => 'application#create_issue'
  post '/submit_issue' => 'application#submit_issue'

  # API routes
  match '*any', via: 'OPTIONS', controller: 'application', action: 'options_req'

  namespace :api, defaults: { format: 'json' }, except: :destroy do
    namespace :v1 do
      get '/projects/:id/key/' => 'projects#key'
      post '/projects/:id/jsonDataUpload' => 'data_sets#jsonDataUpload'
      post '/projects/:id/add_key' => 'projects#add_key'
      post '/data_sets/append' => 'data_sets#append'
      post '/media_objects' => 'media_objects#saveMedia'
      get '/media_objects/:id' => 'media_objects#show'
      get '/users/myInfo' => 'users#my_info'
      resources :projects, only: [:show, :index, :create, :add_key]
      resources :fields, only: [:create, :show]
      resources :formula_fields, only: [:create, :show]
      resources :visualizations, only: [:show]
      resources :data_sets, only: [:show, :edit, :jsonDataUpload]
    end
  end
  get '/testing' => 'testing#index'
  post '/testing/review' => 'testing#review'
  post '/testing/publish' => 'testing#publish'
end
