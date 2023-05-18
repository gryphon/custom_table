CustomTable::Engine.routes.draw do

  resources :settings, only: [:edit, :update]

end
