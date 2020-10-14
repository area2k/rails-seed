# frozen_string_literal: true

require 'active_support/concern'

module Authentication
  extend ActiveSupport::Concern

  AUTHORIZATION_HEADER = Global.headers.authorization
  CLIENT_HEADER = Global.headers.client
  CLIENT_VERSION_HEADER = Global.headers.client_version
  NEW_TOKEN_HEADER = Global.headers.new_token
  REFRESH_TOKEN_HEADER = Global.headers.refresh_token
  USER_AGENT_HEADER = 'User-Agent'
  UNKNOWN = '<unknown>'

  def attempt_refresh
    RequestStore[:device] = Device.find_by(refresh_token: refresh_token)
    unless RequestStore[:device]
      Rails.logger.warn "Device not found with token: #{refresh_token}"
      return
    end

    unless RequestStore[:device].active?
      Rails.logger.warn "Current #{RequestStore[:device].id_name} is not active"
      return
    end

    AuthenticationService.refresh(RequestStore[:device], **request_attrs).tap do |token|
      response.set_header(NEW_TOKEN_HEADER, token.to_s)
      Rails.logger.info "#{RequestStore[:device].id_name} refreshed: #{token[:jti]}"
    end
  end

  def client
    RequestStore[:client] ||= request.headers.fetch(CLIENT_HEADER, UNKNOWN)[0...16]
  end

  def client_version
    RequestStore[:client_version] ||= request.headers.fetch(CLIENT_VERSION_HEADER, UNKNOWN)[0...32]
  end

  def ip
    RequestStore[:ip] ||= request.ip
  end

  def refresh_token
    request.headers[REFRESH_TOKEN_HEADER]
  end

  def request_attrs
    { client: client, client_version: client_version, ip: ip, user_agent: user_agent }
  end

  def user_agent
    RequestStore[:user_agent] ||= request.headers.fetch(USER_AGENT_HEADER, UNKNOWN)[0...255]
  end

  def verify_token
    RequestStore[:request_token] = request.headers[AUTHORIZATION_HEADER]
    unless RequestStore[:request_token]
      Rails.logger.warn 'Token not present in request'
      return
    end

    RequestStore[:token] = AuthenticationService.verify(RequestStore[:request_token])
    unless RequestStore[:token]
      Rails.logger.warn 'Token not valid/whitelisted'
      RequestStore[:token] = attempt_refresh if refresh_token.present?
    end
    unless RequestStore[:token]
      Rails.logger.warn 'Token was not able to be refreshed'
      return
    end

    RequestStore[:device_id] = RequestStore[:token][:sub]
    RequestStore[:actor_key] = RequestStore[:token][:actor]

    Rails.logger.info "Authenticated Device##{RequestStore[:device_id]}" \
                      " (#{RequestStore[:token][:jti]})"
  end
end
