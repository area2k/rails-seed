# frozen_string_literal: true

class GraphQLController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_token

  def execute
    result = if params[:_json]
               GraphQLService.multiplex(params[:_json], context: context)
             else
               GraphQLService.execute(params, context: context)
             end

    render json: result
  rescue StandardError => e
    Rails.logger.error e.full_message

    render_graphql_error(e)
  end

  private

  def context
    {
      device: RequestStore[:device],
      device_id: RequestStore[:device_id],
      request: {
        app_version: app_version,
        id: RequestStore[:request_id] ||= request.request_id,
        ip: ip,
        platform: platform,
        token: RequestStore[:request_token],
        user_agent: user_agent
      },
      token: RequestStore[:token],
      user_id: RequestStore[:user_id]
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
