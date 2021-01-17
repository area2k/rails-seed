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
    # NOTE: add known actor types here
    when 'User' then User
    else
      raise ArgumentError, "Unkown actor type `#{type}`!"
    end
  end

  def current_actor_id
    context[:actor_key][:id]
  end

  def current_actor_parent_id
    context[:actor_key][:parent_id]
  end

  def current_device
    context.fetch(:device) do
      context[:device] = Device.find_by(id: context[:device_id])
    end
  end

  def current_user
    context.fetch(:user) do
      User.find_by(id: current_device.user_id)
    end
  end

  def permitted?(**)
    true
  end

  def prescreen?(**)
    return true unless self.class.allowed_actors.present?

    self.class.allowed_actors.reduce(false) { |acc, elem| acc || actor_is?(elem) }
  end

  def ready?(**args)
    prescreen?(**args).tap do |allowed|
      error! message: 'Not allowed', code: :AUTHORIZATION_FAILED unless allowed
    end
  end

  included do
    class_attribute :allowed_actors
  end

  class_methods do
    def allow_actors(*actors)
      self.allowed_actors = actors
    end
  end
end
