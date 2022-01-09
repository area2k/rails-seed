# frozen_string_literal: true

class ActorKind < Enum
  # TODO: create your actor types, remove this placeholder
  USER = User

  def self.from_str(kind)
    case kind.downcase
    when 'user' then USER
    else
      raise ArgumentError, "Unknown actor kind: #{kind}"
    end
  end
end
