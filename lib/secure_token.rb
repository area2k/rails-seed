# frozen_string_literal: true

class SecureToken
  SIGNING_SECRET = Rails.application.credentials.jwt_secret!

  attr_accessor :claims

  delegate :[], :[]=, to: :claims

  def initialize(ttl: Global.auth.token_ttl, **claims)
    @claims = claims
    @claims[:exp] ||= Time.now.to_i + ttl
    @claims[:jti] ||= SecureRandom.hex(8)
  end

  def expired?
    @claims.key?(:exp) && @claims[:exp] <= Time.now.to_i
  end

  def to_s
    @to_s ||= JWT.encode(@claims, SIGNING_SECRET, Global.auth.jwt_alg)
  end
end
