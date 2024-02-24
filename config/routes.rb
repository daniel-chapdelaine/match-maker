Rails.application.routes.draw do
  root to: "match_maker#new"
  get '/submit', to: 'match_maker#submit'
  get '/superlatives', to: 'superlatives#submit'
end
