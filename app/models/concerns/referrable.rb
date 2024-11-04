# frozen_string_literal: true

module Referrable
  extend ActiveSupport::Concern

  included do
    belongs_to :referrer, class_name: "User", optional: true
    has_many :referees, class_name: "User", inverse_of: :referrer, dependent: :nullify

    validate :referrer_must_exist, on: :update, if: :referrer_id_changed?
    validate :referrer_cannot_be_self, on: :update

    def referral_code
      "R#{uid.to_s.rjust(5, '0')}"
    end

    def referral_link(request)
      "#{request.base_url}/?referral_code=#{referral_code}"
    end

    def referrer_code
      referrer&.referral_code
    end

    private

    def referrer_must_exist
      errors.add(:referrer, "must exist") unless self.class.exists?(referrer_id)
    end

    def referrer_cannot_be_self
      errors.add(:referrer, "can't be you (nice try!)") if referrer == self
    end
  end

  class_methods do
    def find_by_referral_code(code)
      return unless code&.match?(/R\d{5}/)

      find_by(uid: code.gsub(/R0*/, "").to_i)
    end

    def with_aura
      query = <<~SQL.squish
        SELECT
            referrers.uid,
            referrers.username,
            COUNT(referees.id) AS referrals,
            CEIL(100 * (
                LN(COUNT(referees.id) + 1) +                    /* SIGNUPS */
                SUM(LN(COALESCE(completions.total, 0) + 1)) +   /* COMPLETIONS */
                5 * SUM(LN(COALESCE(snippets.total, 0) + 1))    /* CONTRIBUTIONS */
            ))::int AS aura
        FROM users AS referees
        LEFT JOIN users AS referrers
            ON referees.referrer_id = referrers.id
        LEFT JOIN (SELECT user_id, COUNT(id) AS total FROM completions GROUP BY user_id) AS completions
            ON referees.id = completions.user_id
        LEFT JOIN (SELECT user_id, COUNT(id) AS total FROM snippets GROUP BY user_id) AS snippets
            ON referees.id = snippets.user_id
        WHERE referees.referrer_id IS NOT NULL
        GROUP BY 1, 2;
      SQL

      ActiveRecord::Base.connection.exec_query(query, "SQL")
    end
  end
end
