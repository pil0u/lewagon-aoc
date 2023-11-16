# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController, type: :request do
  let(:user) { create :user }

  describe "#slack_openid" do
    let(:omniauth_provider) { :slack_openid }
    let(:omniauth_response) do
      OmniAuth::AuthHash.new({
                               "provider" => "slack_openid",
                               "uid" => "T02NE0241-U0J5GUEAW",
                               "info" => {
                                 "name" => "Jeremie Bonal",
                                 "email" => nil,
                                 "image" => "https://avatars.slack-edge.com/2021-12-01/2809607962064_4559622b7dc8053f87be_512.jpg"
                               },
                               "credentials" => {
                                 "token" => "xoxp-2762002147-18186966370-6167705301863-6ac14f1d343cd9b611a2cb6a463fbb74",
                                 "expires" => false
                               },
                               "extra" => {
                                 "data" => OmniAuth::Strategies::SlackOpenid::INFO_DATA.new(
                                   "U0J5GUEAW",
                                   "T02NE0241",
                                   nil,
                                   nil,
                                   "Jeremie Bonal",
                                   "https://avatars.slack-edge.com/2021-12-01/2809607962064_4559622b7dc8053f87be_512.jpg",
                                   "Jeremie",
                                   "Bonal",
                                   "en-US",
                                   "Le Wagon - Alumni",
                                   "lewagon-alumni"
                                 ),
                                 "raw_info" => {
                                   "ok" => true,
                                   "sub" => "U0J5GUEAW",
                                   "https://slack.com/user_id" => "U0J5GUEAW",
                                   "https://slack.com/team_id" => "T02NE0241",
                                   "name" => "Jeremie Bonal",
                                   "picture" => "https://avatars.slack-edge.com/2021-12-01/2809607962064_4559622b7dc8053f87be_512.jpg",
                                   "given_name" => "Jeremie",
                                   "family_name" => "Bonal",
                                   "locale" => "en-US",
                                   "https://slack.com/team_name" => "Le Wagon - Alumni",
                                   "https://slack.com/team_domain" => "lewagon-alumni",
                                   "https://slack.com/user_image_24" => "https://avatars.slack-edge.com/2021-12-01/282064_457dc8053f87e_24.jpg",
                                   # ... about 20 user avatars url skipped ...
                                   "https://slack.com/team_image_default" => false
                                 }
                               }
                             })
    end

    subject(:omniauth_login) do
      sign_in user
      post "/users/auth/slack_openid"
      follow_redirect!
    end

    let(:slack_response) do
      { "ok" => true,
        "sub" => "U0J5GUEAW",
        "https://slack.com/user_id" => "U0J5GUEAW",
        "https://slack.com/team_id" => "T02NE0241",
        "name" => "Jeremie Bonal",
        "picture" => "https://avatars.slack-edge.com/2021-12-01/2809607962064_4559622b7dc8053f87be_512.jpg",
        "given_name" => "Jeremie",
        "family_name" => "Bonal",
        "locale" => "en-US",
        "https://slack.com/team_name" => "Le Wagon - Alumni",
        "https://slack.com/team_domain" => "lewagon-alumni",
        "https://slack.com/user_image_24" => "https://avatars.slack-edge.com/2021-12-01/2802064_452b7dc8053f87be_24.jpg",
        # ... skipping many image urls ...
        "https://slack.com/team_image_default" => false }
    end
    let(:client_double) { instance_double(Slack::Web::Client, openid_connect_userInfo: slack_response) }
    before do
      allow(Slack::Web::Client).to receive(:new).and_return(client_double)
    end

    it "calls Slack with the provided user access token to get additional info" do
      expect(Slack::Web::Client).to receive(:new)
        .with(token: "xoxp-2762002147-18186966370-6167705301863-6ac14f1d343cd9b611a2cb6a463fbb74")
        .and_return(client_double)
      expect(client_double).to receive(:openid_connect_userInfo)
      omniauth_login
    end

    it "sets the slack UID on the current user" do
      expect { omniauth_login }
        .to change { user.reload.slack_id }.from(nil).to("U0J5GUEAW")
        .and change { user.reload.slack_username }.from(nil).to("Jeremie Bonal")
    end

    it "stores the Slack acess token on the user" do
      expect { omniauth_login }
        .to change { user.reload.slack_access_token }
        .from(nil).to("xoxp-2762002147-18186966370-6167705301863-6ac14f1d343cd9b611a2cb6a463fbb74")
    end

    context "when the OAuth grant failed" do
      let(:omniauth_response) do
        OmniAuth::Strategies::OAuth2::CallbackError.new(
          :access_denied,
          "The user has denied access to the scope(s) requested by the client application.",
          "https://example.com/error"
        )
      end

      it "sets no info on the user" do
        expect { omniauth_login }.not_to(change { user.reload.slack_id })
      end

      it "shows a flash explaining the error" do
        omniauth_login
        expect(session.dig("flash", "flashes", "alert")).to match(/user has denied access/)
      end
    end

    context "when fetching the extra info fails" do
      before do
        allow(client_double).to receive(:openid_connect_userInfo)
          .and_raise(Slack::Web::Api::Errors::TokenRevoked.new("token_revoked"))
      end

      it "sets no info on the user" do
        expect { omniauth_login }.not_to(change { user.reload.slack_id })
      end

      it "shows a flash explaining the error" do
        omniauth_login
        expect(session.dig("flash", "flashes", "alert")).to match(/Info fetch failed.*token_revoked/)
      end
    end

    context "when update of the user fails" do
      before do
        allow_any_instance_of(User).to receive(:update!) do |user|
          user.errors.add(:slack_username, :taken)
          raise ActiveRecord::RecordInvalid.new(user)
        end
      end

      it "shows a flash explaining the error" do
        omniauth_login
        expect(session.dig("flash", "flashes", "alert")).to match(/Slack username .* taken/)
      end
    end
  end
end
