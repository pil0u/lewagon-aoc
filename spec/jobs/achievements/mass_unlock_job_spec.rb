# frozen_string_literal: true

require "rails_helper"

RSpec.describe Achievements::MassUnlockJob do
  before do
    unlocker = Class.new(Achievements::MassUnlocker) { def call; end }
    stub_const("Achievements::MyTestMassUnlocker", unlocker)
  end

  it "calls the appropriate Unlocker based on the nature" do
    expect(Achievements::MyTestMassUnlocker).to receive(:call)
    described_class.perform_now(:my_test)
  end

  context "when provided a non-existent achievement" do
    it "raises" do
      expect { described_class.perform_now(:not_real) }
        .to raise_error(/No Achievement.*not_real/)
    end
  end
end
