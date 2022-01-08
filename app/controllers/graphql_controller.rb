# frozen_string_literal: true

class GraphQLController < ApplicationController
  include Authentication

  skip_before_action :verify_authenticity_token

  def execute
    context = create_context(auth: authenticate)

    result = if params[:_json]
               GraphQLService.multiplex(params[:_json], context:)
             else
               GraphQLService.execute(params, context:)
             end

    render json: result
  rescue AuthenticationService::ValidationError => e
    Rails.logger.error e.message
    render_graphql_error(e, code: e.code, status: 200)
  rescue StandardError => e
    Rails.logger.error e.full_message
    render_graphql_error(e)
  end

  private

  def create_context(auth: nil)
    {
      auth: auth,
      authenticated?: auth.present?,
      request: {
        client:,
        client_version:,
        ip:,
        user_agent:,
        id: request_id,
        token: request_token
      }
    }
  end

  def render_graphql_error(error, code: 'SERVER_ERROR', status: 500)
    payload = {
      message: error.message,
      locations: [{ line: 1, column: 1 }],
      path: [],
      extensions: { code: }
    }

    render(json: { errors: [payload] }, status:)
  end
end
