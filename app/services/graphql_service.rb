# frozen_string_literal: true

module GraphQLService
  module_function

  def execute(query, context:)
    Schema.execute(query[:query], operation_name: query[:operationName],
                                  variables: hasherize(query[:variables]),
                                  context: context)
  end

  def multiplex(queries, context:)
    input = queries.map do |query|
      {
        query: query[:query],
        operation_name: query[:operationName],
        variables: hasherize(query[:variables]),
        context: context
      }
    end

    Schema.multiplex(input)
  end

  ## private ##

  def hasherize(input)
    return {} if input.blank?

    case input
    when String then hasherize(JSON.parse(input))
    when Hash, ActionController::Parameters then input
    else
      raise ArgumentError, "Unexpected parameter: #{input.inspect}"
    end
  end
  private_class_method :hasherize
end
