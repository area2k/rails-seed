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

  %i[actor actor_type actor_id actor_parent_id device device_id token user user_id].each do |name|
    define_method("current_#{name}") do
      context[:auth].public_send(name)
    end
  end

  def actor_is?(...)
    context[:auth].actor_is?(...)
  end

  def authenticate_user(email:, password:)
    user = User.find_by(email: email)
    return Failure(:invalid_login) unless user&.valid_password?(password)

    Success(user)
  end

  def authenticated?
    context[:authenticated?]
  end

  def authorized?(**args)
    permitted?(**args).tap do |permitted|
      error! message: 'Not permitted', code: :AUTHORIZATION_FAILED unless permitted
    end
  end

  def login_actor(actor, **device_attrs)
    device = actor.devices.create!(**request_attrs, **device_attrs, actor_parent_id: actor.parent_id)
    token = AuthenticationService.issue(device.id, jti: device.last_issued,
                                                   actor: actor.to_actor_key)

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
      error! message: 'Not allowed', code: :AUTHORIZATION_FAILED unless allowed
    end
  end

  def request_attrs
    context[:request].slice(:client, :client_version, :ip, :user_agent)
  end
end
