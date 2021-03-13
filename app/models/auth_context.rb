# frozen_string_literal: true

class AuthContext
  attr_reader :token

  def initialize(secure_token, device: nil)
    @token = secure_token
    @device = device
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
    # TODO: add known actor types here
    when 'User' then User
    else
      raise ArgumentError, "Unkown actor type `#{type}`!"
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
