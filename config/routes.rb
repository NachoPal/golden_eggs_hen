Rails.application.routes.draw do

  get 'generated-reports/:id/' => 'reports#generate', as: 'generate_reports', :defaults => { :format => 'pdf' }


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
