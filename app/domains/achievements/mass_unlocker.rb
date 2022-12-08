# frozen_string_literal: true

module Achievements
  class MassUnlocker
    class << self
      def call(...)
        new(...).call
      end

      def nature
        @nature ||= name.split("::").last.gsub("MassUnlocker", "").underscore.to_sym
      end
    end

    def unlock_for!(users, at: Time.now.utc)
      return unless users.any?

      # Idempotency
      already_unlocked = Achievement.where(nature: self.class.nature).select(:user_id)
      to_unlock_for = User.where(id: users).where.not(id: already_unlocked)
      return unless to_unlock_for.any?

      to_create = to_unlock_for.pluck(:id).map do |user_id|
        {
          user_id:,
          nature: self.class.nature,
          unlocked_at: at
        }
      end
      Achievement.insert_all(to_create)
    end
  end
end
