# frozen_string_literal: true

RSpec.describe KSEF::ValueObjects::Mode do
  describe "#initialize" do
    it "accepts symbol value" do
      mode = described_class.new(:test)
      expect(mode.value).to eq :test
    end

    it "accepts string value" do
      mode = described_class.new("production")
      expect(mode.value).to eq :production
    end

    it "raises error for invalid mode" do
      expect { described_class.new(:invalid) }.to raise_error(KSEF::ValidationError)
    end
  end

  describe "mode predicates" do
    it "returns correct predicate for test mode" do
      mode = described_class.new(:test)
      expect(mode.test?).to be true
      expect(mode.demo?).to be false
      expect(mode.production?).to be false
    end

    it "returns correct predicate for production mode" do
      mode = described_class.new(:production)
      expect(mode.production?).to be true
      expect(mode.test?).to be false
    end
  end

  describe "#default_url" do
    it "returns test URL for test mode" do
      mode = described_class.new(:test)
      expect(mode.default_url).to eq "https://ksef-test.mf.gov.pl/api/v2"
    end

    it "returns production URL for production mode" do
      mode = described_class.new(:production)
      expect(mode.default_url).to eq "https://ksef.mf.gov.pl/api/v2"
    end
  end
end
