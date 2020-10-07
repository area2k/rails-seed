# frozen_string_literal: true

require 'active_support/concern'

module Authentication
  extend ActiveSupport::Concern

  AUTHORIZATION_HEADER = Global.headers.authorization
  CLIENT_HEADER = Global.headers.client
  CLIENT_VERSION_HEADER = Global.headers.client_version
  NEW_TOKEN_HEADER = Global.headers.new_token
  USER_AGENT_HEADER = 'User-Agent'
  UNKNOWN = '<unknown>'

  def attempt_refresh
    request_token = SecureToken.decode!(RequestStore[:request_token])

    RequestStore[:device] = Device.find_by(id: request_token[:sub])
    unless RequestStore[:device]
      Rails.logger.warn "Device not found with id: #{request_token[:sub]}"
      return
    end

    unless RequestStore[:device].active?
      Rails.logger.warn "Current #{RequestStore[:device].id_name} is not active"
      return
    end

    AuthenticationService.issue(RequestStore[:device]).tap do |token|
      RequestStore[:device].refresh!(jti: token[:jti], **request_attrs)
      response.set_header(NEW_TOKEN_HEADER, token.to_s)

      Rails.logger.info "#{RequestStore[:device].id_name} refreshed: #{token.jti}"
    end
  rescue JWT::DecodeError
    Rails.logger.warn 'Token could not be decoded'
    nil
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
      RequestStore[:token] = attempt_refresh
    end
    unless RequestStore[:token]
      Rails.logger.warn 'Token was not able to be refreshed'
      return
    end

    RequestStore[:device_id] = RequestStore[:token][:sub]

    Rails.logger.info "Authenticated Device##{RequestStore[:device_id]}" \
                      " (#{RequestStore[:token][:jti]})"
  end
end
