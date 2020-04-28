# TODO: change name to application name
YourApplication::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  mount GraphiQL::Rails::Engine, at: '/graphql', graphql_path: '/graphql'

  post '/graphql', to: 'graphql#execute'
end
