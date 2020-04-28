env = Rails.env.production? ? '' : " [#{Rails.env}]"

# TODO: change with your app name
GraphiQL::Rails.config.title = "YourApp GraphQL#{env}"
GraphiQL::Rails.config.logo = "YourApp GraphQL#{env}"

GraphiQL::Rails.config.initial_query = <<~GRAPHQL
  #
  #  Interactive GraphQL
  #
  #  Keyboard shortcuts:
  #
  #  Prettify Query:  Shift-Ctrl-P (or press the prettify button above)
  #
  #       Run Query:  Ctrl-Enter (or press the play button above)
  #
  #   Auto Complete:  Ctrl-Space (or just start typing)
  #

GRAPHQL
