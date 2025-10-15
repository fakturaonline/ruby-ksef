# frozen_string_literal: true

RSpec.describe KSEF::Support::Utility do
  describe ".retry" do
    it "returns result on first success" do
      result = described_class.retry(backoff: 0.01, retry_until: 1) do
        "success"
      end

      expect(result).to eq "success"
    end

    it "retries until success" do
      attempt = 0
      result = described_class.retry(backoff: 0.01, retry_until: 1) do
        attempt += 1
        attempt == 3 ? "success" : nil
      end

      expect(result).to eq "success"
      expect(attempt).to eq 3
    end

    it "raises error on timeout" do
      expect do
        described_class.retry(backoff: 0.01, retry_until: 0.05) do
          nil
        end
      end.to raise_error(KSEF::Error, /Retry timeout/)
    end

    it "retries with specified backoff" do
      attempts = []

      described_class.retry(backoff: 0.1, retry_until: 0.5) do |*|
        attempts << Time.now
        attempts.length == 3 ? "done" : nil
      end

      # Check that there's roughly 0.1s between attempts
      time_diffs = attempts.each_cons(2).map { |a, b| b - a }
      expect(time_diffs.all? { |diff| diff >= 0.09 }).to be true
    end
  end

  describe ".deep_merge" do
    it "merges simple hashes" do
      hash1 = { a: 1, b: 2 }
      hash2 = { b: 3, c: 4 }

      result = described_class.deep_merge(hash1, hash2)
      expect(result).to eq({ a: 1, b: 3, c: 4 })
    end

    it "deep merges nested hashes" do
      hash1 = { a: { b: 1, c: 2 } }
      hash2 = { a: { c: 3, d: 4 } }

      result = described_class.deep_merge(hash1, hash2)
      expect(result).to eq({ a: { b: 1, c: 3, d: 4 } })
    end

    it "overwrites non-hash values" do
      hash1 = { a: 1 }
      hash2 = { a: { b: 2 } }

      result = described_class.deep_merge(hash1, hash2)
      expect(result).to eq({ a: { b: 2 } })
    end
  end

  describe ".snake_case" do
    it "converts camelCase to snake_case" do
      expect(described_class.snake_case("fooBar")).to eq "foo_bar"
      expect(described_class.snake_case("fooBarBaz")).to eq "foo_bar_baz"
    end

    it "converts PascalCase to snake_case" do
      expect(described_class.snake_case("FooBar")).to eq "foo_bar"
    end

    it "handles already snake_case" do
      expect(described_class.snake_case("foo_bar")).to eq "foo_bar"
    end
  end

  describe ".camel_case" do
    it "converts snake_case to camelCase" do
      expect(described_class.camel_case("foo_bar")).to eq "fooBar"
      expect(described_class.camel_case("foo_bar_baz")).to eq "fooBarBaz"
    end

    it "handles already camelCase" do
      expect(described_class.camel_case("fooBar")).to eq "fooBar"
    end
  end

  describe ".pascal_case" do
    it "converts snake_case to PascalCase" do
      expect(described_class.pascal_case("foo_bar")).to eq "FooBar"
      expect(described_class.pascal_case("foo_bar_baz")).to eq "FooBarBaz"
    end
  end
end
