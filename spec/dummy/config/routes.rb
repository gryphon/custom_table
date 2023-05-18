Rails.application.routes.draw do
  mount CustomTable::Engine => "/custom_table"
end
