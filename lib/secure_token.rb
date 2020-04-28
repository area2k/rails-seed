# frozen_string_literal: true

class SecureToken
  SECRET = Rails.application.secrets.secret_key_base

  class << self
    def validate!(token)
      payload, _header = JWT.decode(token, SECRET)
      new(payload.deep_symbolize_keys)
    end

    def validate(token)
      validate!(token)
    rescue JWT::DecodeError
      nil
    end
  end

  attr_accessor :claims

  delegate :[], to: :claims

  def initialize(sub:, ttl: Global.auth.token_ttl, **opts)
    @claims = opts
    @claims[:sub] = sub
    @claims[:iss] ||= Global.auth.issuer
    @claims[:jti] ||= SecureRandom.base58
    @claims[:exp] ||= Time.now.to_i + ttl
  end

  def expired?
    @claims[:exp] <= Time.now.to_i
  end

  def method_missing(name, *args, &block)
    @claims.key?(name) ? @claims[name] : super
  end

  def respond_to_missing?(name, *args, &block)
    @claims.key?(name) || super
  end

  def to_s
    @to_s ||= JWT.encode(@claims, SECRET, Global.auth.jwt_alg)
  end
end
