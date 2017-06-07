# frozen_string_literal: true

require "spec_helper"

# Init FactoryDoctor and patch FactoryGirl
TestProf::FactoryDoctor.init

describe TestProf::FactoryDoctor, :transactional do
  before { described_class.start }
  after { described_class.stop }

  # Ensure meta-queries have been performed
  before(:all) { User.first }

  describe "#result" do
    subject(:result) { described_class.result }

    it "is not bad when nothing created" do
      FactoryGirl.build_stubbed(:user)
      User.first
      expect(result).not_to be_bad
      expect(result.count).to eq 0
      expect(result.time).to eq 0
      expect(result.queries_count).to eq 1
    end

    it "detects one useless object" do
      FactoryGirl.create(:user)
      expect(result).to be_bad
      expect(result.count).to eq 1
      expect(result.time).to be > 0
    end

    it "detects not useless object when select" do
      user = FactoryGirl.create(:user)
      user.reload

      expect(result).not_to be_bad
      expect(result.count).to eq 1
      expect(result.queries_count).to eq 1
      expect(result.time).to be > 0
    end

    it "detects not useless object when update" do
      user = FactoryGirl.create(:user)
      user.update!(name: 'Phil')

      expect(result).not_to be_bad
      expect(result.count).to eq 1
      expect(result.queries_count).to eq 1
      expect(result.time).to be > 0
    end

    it "detects many objects" do
      FactoryGirl.create_pair(:user)

      expect(result).to be_bad
      expect(result.count).to eq 2
      expect(result.time).to be > 0
    end

    describe "#ignore" do
      it "does not track create" do
        described_class.ignore do
          FactoryGirl.create(:user)
        end

        expect(result).not_to be_bad
        expect(result.count).to eq 0
        expect(result.time).to eq 0
      end

      it "does not track queries" do
        user = FactoryGirl.create(:user)

        described_class.ignore { user.reload }

        expect(result).to be_bad
        expect(result.count).to eq 1
        expect(result.time).to be > 0
      end
    end
  end
end