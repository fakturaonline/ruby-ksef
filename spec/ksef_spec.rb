# frozen_string_literal: true

RSpec.describe KSEF do
  it "has a version number" do
    expect(KSEF::VERSION).not_to be_nil
  end

  describe ".build" do
    it "returns a client instance" do
      client = described_class.build do
        mode :test
        access_token "test_token"
      end

      expect(client).to be_a(KSEF::Resources::Client)
    end

    it "accepts configuration block" do
      client = described_class.build do
        mode :production
        identifier "1234567890"
      end

      expect(client.config.mode.production?).to be true
      expect(client.config.identifier.value).to eq "1234567890"
    end
  end
end
