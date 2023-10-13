Rails.application.routes.draw do
  devise_for :users
  mount CustomTable::Engine => "/custom_table"

  resources :orders do
    get :another, on: :collection

    get :actions_skip, on: :collection
    get :actions_custom, on: :collection
    get :actions_skip_default, on: :collection
    get :actions_variant, on: :collection

    get :default_search, on: :collection
    get :fields, on: :collection
    get :skip_fields, on: :collection

    get :no_paginate, on: :collection

    get :row, on: :member
  end
  
end
