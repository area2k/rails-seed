# frozen_string_literal: true

module AuthHelpers
  extend ActiveSupport::Concern

  def actor_is?(type)
    authenticated? && current_actor_type == type
  end

  def authenticated?
    context[:actor_key].present?
  end

  def authorized?(**args)
    permitted?(**args).tap do |permitted|
      error! message: 'Not permitted', code: :AUTHORIZATION_FAILED unless permitted
    end
  end

  def current_actor
    context.fetch(:actor) do
      context[:actor] = current_actor_type.find_by(id: current_actor_id)
    end
  end

  def current_actor_type
    case context[:actor_key][:type]
    # NOTE: add actor types here
    when 'User' then User
    else
      raise ArgumentError, "Unkown actor type `#{type}`!"
    end
  end

  def current_actor_id
    context[:actor_key][:id]
  end

  def current_device
    context.fetch(:device) do
      context[:device] = Device.find(context[:device_id])
    end
  end

  def current_user
    context.fetch(:user) do
      User.find_by(id: current_device.user_id)
    end
  end

  def permitted?(**kwargs)
    true
  end

  def prescreen?(**kwargs)
    true
  end

  def ready?(**args)
    prescreen?(**args).tap do |allowed|
      error! message: 'Not allowed', code: :AUTHORIZATION_FAILED unless allowed
    end
  end
end
