# frozen_string_literal: true

require "rails_helper"

RSpec.describe Achievements::MassUnlocker do
  let(:unlocker) { MyTestMassUnlocker }
  let!(:users) { create_list :user, 5 }

  before do
    target_users = users # trick to bring the collection into scope to be accessed by the proc
    unlocker = Class.new(described_class)
    unlocker.define_method(:call) { unlock_for!(target_users) }
    stub_const("MyTestMassUnlocker", unlocker)
  end

  it "creates an achievement of the correct nature for every user" do
    expect { unlocker.call }
      .to change { Achievement.where(nature: :my_test, user_id: users).count }
      .from(0).to(5)
  end

  it "knows the nature of the achievement associated to the unlocker" do
    expect(unlocker.nature).to eq("my_test")
  end

  context "when some of the users already have the achievement" do
    before do
      users[1].achievements.create!(nature: "my_test")
      users[3].achievements.create!(nature: "my_test")
    end

    it "only creates an achievement for the users that don't already have it" do
      expect { unlocker.call }
        .to change { Achievement.where(nature: :my_test, user_id: users).count }
        .from(2).to(5)
    end
  end
end
