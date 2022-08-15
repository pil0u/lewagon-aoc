# frozen_string_literal: true

class BlazerConstraint
  def matches?(request)
    request.env["warden"].user.blazer?
  end
end
