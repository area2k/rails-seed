# frozen_string_literal: true

require 'active_support/concern'

module Authentication
  extend ActiveSupport::Concern

  AUTHORIZATION_HEADER = Global.headers.authorization
  CLIENT_HEADER = Global.headers.client
  CLIENT_VERSION_HEADER = Global.headers.client_version
  USER_AGENT_HEADER = Global.headers.user_agent
  UNKNOWN = '<unknown>'

  def authenticate
    unless request_token
      Rails.logger.warn 'No token present in request'
      return
    end

    AuthenticationService.validate(request_token).tap do |auth_context|
      if auth_context.present?
        Rails.logger.info "Authenticated #{auth_context.actor_type}##{auth_context.actor_id}"
      end
    end
  end

  def client
    RequestStore[:client] ||= fetch_header(CLIENT_HEADER, max: 16)
  end

  def client_version
    RequestStore[:client_version] ||= fetch_header(CLIENT_VERSION_HEADER, max: 32)
  end

  def ip
    RequestStore[:ip] ||= request.ip
  end

  def request_id
    RequestStore[:request_id] ||= request.request_id
  end

  def request_token
    RequestStore[:request_token] ||= request.headers[AUTHORIZATION_HEADER]
  end

  def user_agent
    RequestStore[:user_agent] ||= fetch_header(USER_AGENT_HEADER, max: 255)
  end

  private

  def fetch_header(name, max:)
    request.headers.fetch(name, UNKNOWN)[0...max]
  end
end
