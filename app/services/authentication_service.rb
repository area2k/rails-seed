# frozen_string_literal: true

module AuthenticationService
  DEVICE_PREFIX = 'tokens:device:'

  TokenNotWhitelisted = Class.new(StandardError)

  module_function

  def issue(device_id, jti: SecureRandom.base36, **attrs)
    SecureToken.new(**attrs, jti: jti, sub: device_id).tap do |token|
      TokenWhitelist.add(token, key: "#{DEVICE_PREFIX}#{device_id}")
    end
  end

  def refresh(device, jti: SecureRandom.base36, **request_attrs)
    issue(device.id, jti: jti, actor: device.actor_key).tap do |token|
      device.refresh(**request_attrs, jti: token[:jti])
    end
  end

  def revoke(device_id)
    TokenWhitelist.remove("#{DEVICE_PREFIX}#{device_id}")
  end

  def revoke_all(*device_ids)
    TokenWhitelist.remove_all(*device_ids.flat_map { |id| "#{DEVICE_PREFIX}#{id}" })
  end

  def verify(jwt)
    verify!(jwt)
  rescue JWT::DecodeError, TokenNotWhitelisted
    nil
  end

  def verify!(jwt)
    SecureToken.validate!(jwt).tap do |token|
      key = "#{DEVICE_PREFIX}#{token[:sub]}"
      raise TokenNotWhitelisted unless TokenWhitelist.whitelisted?(token, key: key)
    end
  end

  class TokenWhitelist
    def self.add(token, key:)
      Redis.current.multi do
        Redis.current.zadd(key, token[:exp], token[:jti])
        Redis.current.zremrangebyscore(key, '-inf', "(#{Time.now.to_i}")
        Redis.current.expireat(key, token[:exp])
      end
    end

    def self.remove(key)
      Redis.current.del(key)
    end

    def self.remove_all(*keys)
      Redis.current.del(*keys)
    end

    def self.whitelisted?(token, key:)
      expires_at = Redis.current.zscore(key, token[:jti])
      return false unless expires_at

      expires_at > Time.now.to_i
    end
  end
end
