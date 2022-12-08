# frozen_string_literal: true

module Achievements
  class Unlocker
    class << self
      def call(...)
        new(...).call
      end

      def nature
        @nature ||= name.split("::").last.gsub("Unlocker", "").underscore.to_sym
      end

      def inherited(klass)
        super
        # Prepending so we don't need to remember to include it in each implem
        klass.prepend Idempotency
      end
    end

    def initialize(user)
      @user = user
    end
    attr_reader :user

    def unlock!(at: Time.now.utc)
      Achievement.create!(user: @user, nature: self.class.nature, unlocked_at: at)
    end

    # Avoid re-creating achievements
    module Idempotency
      def call
        return if already_has_achievement?(user)

        super
      end

      def already_has_achievement?(user)
        user.achievements.exists?(nature: self.class.nature)
      end
    end
  end
end
