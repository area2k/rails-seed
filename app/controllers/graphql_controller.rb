# frozen_string_literal: true

class GraphQLController < ApplicationController
  include Authentication

  skip_before_action :verify_authenticity_token

  def execute
    context = create_context(auth: authenticate)

    result = if params[:_json]
               GraphQLService.multiplex(params[:_json], context: context)
             else
               GraphQLService.execute(params, context: context)
             end

    render json: result
  rescue AuthenticationService::ValidationError => err
    Rails.logger.error err.message
    render_graphql_error(err, code: err.code, status: 200)
  rescue StandardError => err
    Rails.logger.error err.full_message
    render_graphql_error(err)
  end

  private

  def create_context(auth: nil)
    {
      auth: auth,
      authenticated?: auth.present?,
      request: {
        client: client,
        client_version: client_version,
        id: request_id,
        ip: ip,
        token: request_token,
        user_agent: user_agent
      }
    }
  end

  def render_graphql_error(error, code: 'SERVER_ERROR', status: 500)
    payload = {
      message: error.message,
      locations: [{ line: 1, column: 1 }],
      path: [],
      extensions: { code: code }
    }

    render json: { errors: [payload] }, status: status
  end
end
