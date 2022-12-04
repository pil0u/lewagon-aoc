# frozen_string_literal: true

require "rails_helper"

RSpec.describe Achievements::UnlockJob do
  let(:user) { create :user }

  before do
    unlocker = Class.new(Achievements::Unlocker) { def call; end }
    stub_const("Achievements::MyTestUnlocker", unlocker)
  end

  it "calls the appropriate Unlocker with the user based on the nature" do
    expect(Achievements::MyTestUnlocker).to receive(:call).with(user)
    described_class.perform_now(:my_test, user.id)
  end

  context "when provided a non-existent user" do
    it "raises" do
      expect { described_class.perform_now(:my_test, 404) }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when provided a non-existent achievement" do
    it "raises" do
      expect { described_class.perform_now(:not_real, user.id) }
        .to raise_error(/No Achievement.*not_real/)
    end
  end
end
