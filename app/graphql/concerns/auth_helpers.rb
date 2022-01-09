# frozen_string_literal: true

module AuthHelpers
  extend ActiveSupport::Concern

  included do
    class_attribute :allowed_actors
  end

  class_methods do
    def allow_actors(*actors)
      self.allowed_actors = actors
    end
  end

  %i[actor actor_kind actor_id actor_parent_id device device_id token user user_id].each do |name|
    define_method("current_#{name}") do
      auth_context.public_send(name)
    end
  end

  def actor_is?(...)
    auth_context.actor_is?(...)
  end

  def auth_context
    context[:auth]
  end

  def authenticated?
    context[:authenticated?]
  end

  def authorized?(**args)
    permitted?(**args).tap do |permitted|
      error! 'AUTHORIZATION_FAILED', message: 'Not permitted' unless permitted
    end
  end

  def login_actor(actor, **device_attrs)
    attrs = { **request_attrs, **device_attrs, actor_parent_id: actor.parent_id }
    device = actor.devices.create!(attrs)

    claims = { jti: device.last_issued, actor: actor.to_actor_key }
    token = AuthenticationService.issue(device.id, **claims)

    [device, token]
  end

  def permitted?(**)
    true
  end

  def prescreen?(**)
    return true unless self.class.allowed_actors.present?

    authenticated? && actor_is?(*self.class.allowed_actors)
  end

  def ready?(**args)
    prescreen?(**args).tap do |allowed|
      error! 'AUTHORIZATION_FAILED', message: 'Not allowed' unless allowed
    end
  end

  def request_attrs
    context[:request].slice(:client, :client_version, :ip, :user_agent)
  end
end
