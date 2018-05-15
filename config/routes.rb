Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  root 'account#index'
  post '/sign_up' => 'account#signup', as: :sign_up
  get '/login' => 'account#login', as: :log_in
  get '/logout' => 'account#logout', as: :log_out
  get '/account_settings/:id' => 'account#settings', as: :account_settings
  put '/change_password/:id' => 'account#changePassword', as: :change_password
  patch '/change_avatar/:id' => 'account#changeAvatar', as: :change_avatar
  delete '/remove_avatar/:id' => 'account#removeAvatar', as: :remove_avatar
  
  get '/events' => 'eats#index', as: :eats_wall
  get '/notifications' => 'eats#notifications', as: :notifications
  post '/add_event' => 'eats#newEvent', as: :add_event
  get '/edit_event/:id' => 'eats#editEvent', as: :edit_event
  put '/update_event/:id' => 'eats#updateEvent', as: :update_event
  get '/delete_event/:id' => 'eats#deleteEvent', as: :delete_event
  delete '/remove_tag/:event_id/:acc_id' => 'eats#removeSingleTag', as: :remove_tag
  
  get '/profile/:id' => 'eats#showProfile', as: :showProfile
  get '/event/:id' => 'eats#showEvent', as: :showEvent
  get '/group/:id' => 'eats#showGroupProfile', as: :show_group_profile
  
  post '/create_group' => 'eats#createGroup', as: :create_group
  delete '/delete_group/:id' => 'eats#deleteGroup', as: :delete_group
  post '/memberschange/:id' => 'eats#membersUpdate', as: :group_members_update
  get '/to_admin/:group_id/:acc_id' => 'eats#changeToAdmin', as: :change_to_admin
  get '/remove_from_admin/:group_id/:acc_id' => 'eats#removeFromAdmin', as: :remove_from_admin
  get '/join_group/:group_id/:acc_id' => 'eats#joinGroup', as: :join_group
  get '/join_request_response/:accept/:group_id/:acc_id' => 'eats#joinGroupResponse', as: :join_group_response
  
  get '/suggestInput/:name/:id/:with_group' => 'eats#suggestInput', as: :suggestInput
  get '/suggestInput/' => 'eats#suggestInput', as: :emptySuggestInput
  get '/addTag/:tags' => 'eats#addTag', as: :addTag
  get '/addTag/' => 'eats#addTag', as: :addEmptyTag
  get '/removeTag/:tags/:id' => 'eats#removeTag', as: :removeTag
  get '/addSearchList/:searches' => 'eats#addSearchList', as: :addSearchList
  get '/addSearchList/' => 'eats#addSearchList', as: :addEmptySearchList
  get '/removeSearch/:searches/:id' => 'eats#removeSearch', as: :removeSearch
  
  get '/searchSchedules/:ids' => 'eats#searchSchedules', as: :searchSchedules
  get '/searchSchedules/' => 'eats#searchSchedules', as: :emptySearchSchedules
  
  get '/addMemberList/:ids' => 'eats#addMemberList', as: :addMemberList
  get '/addMemberList/' => 'eats#addMemberList', as: :emptyMemberList
  get '/removeAddMember/:ids/:id' => 'eats#removeAddMember', as: :removeAddMember
  
  get '/editAddTag/:tags' => 'eats#editAddTag', as: :editAddTag
  get '/editAddTag/' => 'eats#editAddTag', as: :editAddEmptyTag
  get '/editRemoveTag/:tags/:id' => 'eats#editRemoveTag', as: :editRemoveTag
  
  get '/load_calendar/:view_type/:day/:ids' => 'eats#loadCalendar', as: :load_calendar
  get '/load_calendar/:view_type/:day/' => 'eats#loadCalendar', as: :load_empty_calendar
end
