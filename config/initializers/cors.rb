Rails.application.config.middleware.use Rack::Cors do
  allow do
    origins '*'
    resource '/graphql', headers: :any,
                         methods: %i[get post options],
                         expose: [Global.headers.request_id, Global.headers.new_token]
  end
end
