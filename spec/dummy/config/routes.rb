Rails.application.routes.draw do
  devise_for :users
  mount CustomTable::Engine => "/custom_table"

  resources :orders do
    get :another, on: :collection
  end
  
end
