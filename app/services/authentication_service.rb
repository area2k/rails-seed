# frozen_string_literal: true

module AuthenticationService
  KEY_PREFIX = 'tokens:user:'

  RefreshTokenNotFound = Class.new(StandardError)

  module_function

  def deauthorize(user_id)
    Device.where(user_id: user_id).update_all(expires_at: 0)
    revoke_all(user_id)
  end

  def deactivate(device)
    device.update!(expires_at: 0)
    revoke(device.user_id, jti: device.last_issued)
  end

  def issue(user, **attrs)
    attrs[:last_issued] = SecureRandom.base36
    device = user.devices.create!(**attrs)

    token = SecureToken.new(sub: user.id, jti: attrs[:last_issued], d: device.id)
    add_to_whitelist(token)

    [device, token]
  end

  def refresh(device, **attrs)
    SecureToken.new(sub: device.user_id, d: device.id).tap do |token|
      add_to_whitelist(token)
      device.refresh(**attrs, jti: token.jti)
    end
  end

  def revoke(user_id, jti:)
    Redis.current.zrem("#{KEY_PREFIX}#{user_id}", jti)
  end

  def revoke_all(user_id)
    Redis.current.del("#{KEY_PREFIX}#{user_id}")
  end

  def verify(jwt)
    SecureToken.validate!(jwt).tap do |token|
      return nil unless whitelisted?(token)
    end
  rescue JWT::DecodeError
    nil
  end

  ## private ##

  def add_to_whitelist(token)
    key = "#{KEY_PREFIX}#{token.sub}"

    Redis.current.multi do
      Redis.current.zadd(key, token.exp, token.jti)
      Redis.current.zremrangebyscore(key, '-inf', "(#{Time.now.to_i}")
      Redis.current.expireat(key, token.exp)
    end
  end
  private_class_method :add_to_whitelist

  def whitelisted?(token)
    key = "#{KEY_PREFIX}#{token[:sub]}"
    token_expiration = Redis.current.zscore(key, token[:jti])

    token_expiration.present? && token_expiration > Time.now.to_i
  end
  private_class_method :whitelisted?
end
