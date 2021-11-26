module Helpers
  module GraphQL
    DEFAULT_CONTEXT = {
      auth: nil,
      authenticated?: false,
      request: {}
    }

    def build_auth_context(device_id: 1, actor_id: 1, actor_type: 'User', actor_parent_id: nil)
      AuthenticationService::AuthContext.new(
        sub: device_id,
        actor: {
          id: actor_id,
          type: actor_type,
          parent_id: actor_parent_id
        }
      )
    end

    def build_context(**opts)
      @context = { **DEFAULT_CONTEXT, **opts }
      @context[:authenticated?] = @context[:auth].present?

      @context
    end

    def execute_query(query, **variables)
      ctx = @context || build_context

      @result = Schema.execute(query, variables: variables, context: ctx)
      @data = @result['data']
      @errors = @result['errors']
    end

    def expect_no_errors
      expect(@errors).to be_empty
    end

    def expect_no_problem_with(data_key)
      expect(@data[data_key]['problem']).to be_nil
    end

    def expect_problem_with(data_key, problem_code)
      expect(@data[data_key]['problem']['code']).to eq problem_code
    end
  end
end
