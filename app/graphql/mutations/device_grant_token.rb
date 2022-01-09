# frozen_string_literal: true

module Mutations
  class DeviceGrantToken < BaseMutation
    description 'Exchange a device token for an access token'

    argument :actor, Inputs::ActorInput, required: true, autofetch: :fetch_actor
    argument :device_token, String, required: true, autofetch: :fetch_device, as: :device

    field :access_token, String, null: true
    field :device_token, String, null: true

    define_problems do
      problem :device_expired, path: %w[],
        description: 'Occurs when a device is no longer able to be refreshed'
      problem :invalid_actor, path: %w[actor],
        description: 'Occurs when the actor is not found or is unable to be granted a token'
      problem :invalid_token, path: %w[refreshToken],
        description: 'Occurs when the given refreshToken is invalid'
    end

    def resolve(device:, actor:)
      raise Problems::INVALID_ACTOR unless actor.user_id == device.user_id

      token = AuthenticationService.issue(device.id, actor: actor.to_actor_key)
      device.refresh(**request_attrs, jti: token[:jti])

      { access_token: token.to_s, device_token: device.refresh_token }
    end

    private

    def fetch_actor(actor_input)
      actor_input[:kind].find_by(uuid: actor_input[:id]).tap do |actor|
        raise Problems::INVALID_ACTOR unless actor
      end
    end

    def fetch_device(refresh_token)
      Device.find_by(refresh_token:).tap do |device|
        raise Problems::INVALID_TOKEN if device.nil?
        raise Problems::DEVICE_EXPIRED if device.expired?
      end
    end
  end
end
