# frozen_string_literal: true

class SyncedConstraint
  def matches?(request)
    request.env["warden"].user.synced?
  end
end
