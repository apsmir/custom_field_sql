Rails.application.routes.draw do
  match '/custom_sql_search/search', :to => 'custom_sql_search#search', :via => :get
end
