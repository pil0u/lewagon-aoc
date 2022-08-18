# frozen_string_literal: true

class ConfirmedConstraint
  def matches?(request)
    request.env["warden"].user.confirmed?
  end
end
