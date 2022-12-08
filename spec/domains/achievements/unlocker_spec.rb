# frozen_string_literal: true

require "rails_helper"

RSpec.describe Achievements::Unlocker do
  let(:unlocker) { MyTestUnlocker }
  let!(:user) { create :user }

  before do
    stub_const("MyTestUnlocker", Class.new(described_class) { def call = unlock! })
  end

  it "creates an achievement of the correct nature for the user" do
    expect { unlocker.call(user) }.to change { user.achievements.where(nature: "my_test").count }.from(0).to(1)
  end

  it "knows the nature of the achievement associated to the unlocker" do
    expect(unlocker.nature).to eq(:my_test)
  end

  context "when the user already has the achievement" do
    before do
      user.achievements.create!(nature: "my_test")
    end

    it "doesn't perform any check again" do
      expect_any_instance_of(unlocker).not_to receive(:unlock!)
      unlocker.call(user)
    end
  end
end
