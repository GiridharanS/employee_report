Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  get 'dashboard', to: 'employees#dashboard'
  post 'import', to: 'employees#import'
  get 'export', to: 'employees#export'
  # Defines the root path route ("/")
  root "employees#dashboard"
end
