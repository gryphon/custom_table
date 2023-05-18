Rails.application.routes.draw do
  devise_for :users
  mount CustomTable::Engine => "/custom_table"

  resources :orders
  
end
