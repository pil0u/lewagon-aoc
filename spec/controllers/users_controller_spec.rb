# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController do
  let(:user) { create :user, slack_id: "ABCDF", slack_username: "Hi" }

  describe "#unlink_slack" do
    before { sign_in user }

    it "clears the slack-related attributes on the user" do
      expect { delete :unlink_slack }
        .to change { user.reload.slack_id }.to(nil)
        .and change { user.reload.slack_username }.to(nil)
    end

    context "when the update fails" do
      before do
        allow_any_instance_of(User).to receive(:update) do |user, *_attrs|
          user.errors.add :slack_id, :blank # Imagining we make it un-unlinkable later
          false
        end
      end

      it "redirects with a flash about the errors" do
        delete :unlink_slack
        expect(session.dig("flash", "flashes", "alert")).to match(/Slack can't be blank/)
      end
    end
  end
end
