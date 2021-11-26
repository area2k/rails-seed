# frozen_string_literal: true

module AuthenticationService
  SIGNING_SECRET = Rails.application.credentials.jwt_secret!

  module_function

  def issue(device_id, jti: SecureRandom.hex(8), **attrs)
    SecureToken.new(**attrs, jti: jti, sub: device_id)
  end

  def refresh(device, jti: SecureRandom.hex(8), **request_attrs)
    issue(device.id, jti: jti, actor: device.actor_key).tap do |token|
      device.refresh(**request_attrs, jti: token[:jti])
    end
  end

  def validate(request_token)
    payload, = JWT.decode(request_token, nil, false)

    options = { algorithm: Global.auth.jwt_alg }
    JWT.decode(request_token, SIGNING_SECRET, true, options)

    AuthContext.new(payload.deep_symbolize_keys)
  rescue JWT::ExpiredSignature
    raise ValidationError.new('Token is expired', code: :TOKEN_EXPIRED)
  # rescue JWT::MissingRequiredClaim
  #   raise ValidationError.new('Token is missing required claims', code: :TOKEN_MALFORMED)
  rescue JWT::VerificationError
    raise ValidationError.new('Token signature invalid', code: :TOKEN_INVALID)
  rescue JWT::DecodeError
    raise ValidationError.new('Token cannot be decoded', code: :TOKEN_DECODE_ERROR)
  end

  class ValidationError < StandardError
    attr_reader :code

    def initialize(message, code:)
      super(message)
      @code = code
    end
  end

  class AuthContext
    attr_reader :token

    delegate :[], to: :token

    def initialize(jwt_payload)
      @token = jwt_payload
    end

    def actor
      @actor ||= actor_type.find_by(id: actor_id)
    end

    def actor_id
      actor_key[:id]
    end

    def actor_is?(*types)
      types.include?(actor_type)
    end

    def actor_key
      token[:actor]
    end

    def actor_parent_id
      actor_key[:parent_id]
    end

    def actor_type
      case actor_key[:type]
      # TODO: add your actor types here
      when 'User' then User
      else
        raise ArgumentError, "Unkown actor type: #{type}"
      end
    end

    def device
      @device ||= Device.find_by(id: device_id)
    end

    def device_id
      token[:sub]
    end

    def user
      @user ||= actor.user
    end

    def user_id
      actor.user_id
    end
  end
end
