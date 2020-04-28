# frozen_string_literal: true

require 'active_support/concern'

module Authentication
  extend ActiveSupport::Concern

  APP_VERSION_HEADER = Global.headers.app_version
  AUTHORIZATION_HEADER = Global.headers.authorization
  NEW_TOKEN_HEADER = Global.headers.new_token
  PLATFORM_HEADER = Global.headers.platform
  REFRESH_HEADER = Global.headers.refresh_token
  USER_AGENT_HEADER = 'User-Agent'
  UNKNOWN = '<unknown>'

  def app_version
    RequestStore[:app_version] ||=
      request.headers.fetch(APP_VERSION_HEADER, UNKNOWN)[0...32]
  end

  def attempt_refresh
    unless request.headers[REFRESH_HEADER].present?
      Rails.logger.warn 'Refresh token not present in request'
      return
    end

    RequestStore[:device] = Device.find_by(refresh_token: request.headers[REFRESH_HEADER])
    unless RequestStore[:device]&.active?
      Rails.logger.warn 'Current device not active'
      return
    end

    AuthenticationService.refresh(RequestStore[:device], request_info).tap do |token|
      Rails.logger.info "Refreshed Device##{RequestStore[:device].id}: #{token.jti}"
      response.set_header(NEW_TOKEN_HEADER, token.to_s)
    end
  end

  def ip
    RequestStore[:ip] ||= request.ip
  end

  def platform
    RequestStore[:platform] ||=
      request.headers.fetch(PLATFORM_HEADER, UNKNOWN)[0...16]
  end

  def request_info
    { app_version: app_version, ip: ip, platform: platform, user_agent: user_agent }
  end

  def user_agent
    RequestStore[:user_agent] ||=
      request.headers.fetch(USER_AGENT_HEADER, UNKNOWN)[0...255]
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
      Rails.logger.warn 'Device not able to refresh token'
      return
    end

    RequestStore[:user_id] = RequestStore[:token].sub
    RequestStore[:device_id] = RequestStore[:token].d

    Rails.logger.info "Authenticated u:#{RequestStore[:user_id]}" \
                      " d:#{RequestStore[:device_id]}" \
                      " jti:#{RequestStore[:token].jti}"
  end
end
