# frozen_string_literal: true

module KSEF
  module Support
    # Utility helper methods
    module Utility
      # Retry a block until it returns a truthy value or timeout
      # @param backoff [Integer] Seconds between retries
      # @param retry_until [Integer] Maximum total seconds to retry
      # @yield Block to retry
      # @return Result of the block
      # @raise [RuntimeError] If timeout reached without success
      def self.retry(backoff: 10, retry_until: 120, &block)
        start_time = Time.now
        attempt = 0

        loop do
          attempt += 1
          result = block.call

          return result if result

          elapsed = Time.now - start_time
          raise Error, "Retry timeout after #{elapsed.round(2)}s (#{attempt} attempts)" if elapsed >= retry_until

          sleep backoff
        end
      end

      # Deep merge two hashes
      def self.deep_merge(hash1, hash2)
        hash1.merge(hash2) do |_key, old_val, new_val|
          if old_val.is_a?(Hash) && new_val.is_a?(Hash)
            deep_merge(old_val, new_val)
          else
            new_val
          end
        end
      end

      # Convert hash keys to snake_case
      def self.deep_snake_case_keys(hash)
        return hash unless hash.is_a?(Hash)

        hash.transform_keys { |k| snake_case(k.to_s) }
            .transform_values { |v| deep_snake_case_keys(v) }
      end

      # Convert hash keys to camelCase
      def self.deep_camel_case_keys(hash)
        return hash unless hash.is_a?(Hash)

        hash.transform_keys { |k| camel_case(k.to_s) }
            .transform_values { |v| deep_camel_case_keys(v) }
      end

      # Convert string to snake_case
      def self.snake_case(str)
        str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .downcase
      end

      # Convert string to camelCase
      def self.camel_case(str)
        str.split("_").map.with_index do |word, i|
          i.zero? ? word : word.capitalize
        end.join
      end

      # Convert string to PascalCase
      def self.pascal_case(str)
        str.split("_").map(&:capitalize).join
      end
    end
  end
end
