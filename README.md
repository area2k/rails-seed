@area2k Rails Seed
==================

## Get started

#### Initial setup only

1. Add your application details by finding all TODO comments.
```ruby
# TODO: rename to your application name
module YourApplication
  class Application < Rails::Application
```

2. Add required credentials for all envs found in `config/credentials.example.yml`.
```sh
rails credentials:edit -e <environment | omit for production>
```

#### After clone or initial setup

3. Run the setup command to configure the local environment and create databases.
```sh
rake setup
```

4. All done!
```sh
rails s
```


> Navigate to `/graphql` to explore the application graph.
