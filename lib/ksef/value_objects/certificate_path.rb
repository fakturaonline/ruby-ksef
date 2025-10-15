# frozen_string_literal: true

module KSEF
  module ValueObjects
    # Path to PKCS#12 certificate with passphrase
    class CertificatePath
      attr_reader :path, :passphrase

      def initialize(path:, passphrase:)
        @path = path
        @passphrase = passphrase
        validate!
      end

      def exists?
        File.exist?(@path)
      end

      def ==(other)
        other.is_a?(self.class) &&
          other.path == @path &&
          other.passphrase == @passphrase
      end

      alias eql? ==

      def hash
        [@path, @passphrase].hash
      end

      private

      def validate!
        raise ValidationError, "Certificate path cannot be nil or empty" if @path.nil? || @path.empty?
        raise ValidationError, "Certificate file does not exist: #{@path}" unless exists?
        raise ValidationError, "Passphrase cannot be nil" if @passphrase.nil?
      end
    end
  end
end
