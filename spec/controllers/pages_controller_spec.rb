# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagesController do
  let!(:referrer) { create :user, uid: "1" }
  let!(:referee_one) { create :user, username: "Aquaj", uid: "2", referrer: }
  let!(:referee_two) { create :user, username: "wJoenn", uid: "3", referrer: }
  let!(:referee_three) { create :user, username: "Aurrou", uid: "4", referrer: referee_one }

  describe "#patrons" do
    it "requires to be authenticated", :logged_out do
      get :patrons

      expect(response).to have_http_status :redirect
    end

    it "queries the username, the amount of referees and the aura for every User" do
      sign_in(referrer)
      get :patrons

      expect(@controller.instance_variable_get(:@users).map(&:as_json)).to contain_exactly(
        hash_including("uid" => "1", "username" => "pil0u", "referrals" => 2, "aura" => 110.0),
        hash_including("uid" => "2", "username" => "Aquaj", "referrals" => 1, "aura" => 70.0),
        hash_including("uid" => "3", "username" => "wJoenn", "referrals" => 0, "aura" => 0.0),
        hash_including("uid" => "4", "username" => "Aurrou", "referrals" => 0, "aura" => 0.0)
      )
    end
  end
end
