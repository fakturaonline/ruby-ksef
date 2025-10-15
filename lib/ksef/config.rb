# frozen_string_literal: true

module KSEF
  # Configuration object for KSEF client
  # Immutable - all changes return new instance
  class Config
    attr_reader :mode, :api_url, :access_token, :refresh_token, :ksef_token,
                :certificate_path, :encryption_key, :encrypted_key, :identifier,
                :logger, :async_max_concurrency

    def initialize(
      mode: ValueObjects::Mode.new(:test),
      api_url: nil,
      access_token: nil,
      refresh_token: nil,
      ksef_token: nil,
      certificate_path: nil,
      encryption_key: nil,
      encrypted_key: nil,
      identifier: nil,
      logger: nil,
      async_max_concurrency: 8
    )
      @mode = mode
      @api_url = api_url || mode.default_url
      @access_token = access_token
      @refresh_token = refresh_token
      @ksef_token = ksef_token
      @certificate_path = certificate_path
      @encryption_key = encryption_key
      @encrypted_key = encrypted_key
      @identifier = identifier
      @logger = logger
      @async_max_concurrency = async_max_concurrency
    end

    # Create new config with updated mode
    def with_mode(mode)
      self.class.new(
        mode: mode,
        api_url: @api_url,
        access_token: @access_token,
        refresh_token: @refresh_token,
        ksef_token: @ksef_token,
        certificate_path: @certificate_path,
        encryption_key: @encryption_key,
        encrypted_key: @encrypted_key,
        identifier: @identifier,
        logger: @logger,
        async_max_concurrency: @async_max_concurrency
      )
    end

    # Create new config with updated API URL
    def with_api_url(api_url)
      self.class.new(
        mode: @mode,
        api_url: api_url,
        access_token: @access_token,
        refresh_token: @refresh_token,
        ksef_token: @ksef_token,
        certificate_path: @certificate_path,
        encryption_key: @encryption_key,
        encrypted_key: @encrypted_key,
        identifier: @identifier,
        logger: @logger,
        async_max_concurrency: @async_max_concurrency
      )
    end

    # Create new config with updated access token
    def with_access_token(token)
      self.class.new(
        mode: @mode,
        api_url: @api_url,
        access_token: token,
        refresh_token: @refresh_token,
        ksef_token: @ksef_token,
        certificate_path: @certificate_path,
        encryption_key: @encryption_key,
        encrypted_key: @encrypted_key,
        identifier: @identifier,
        logger: @logger,
        async_max_concurrency: @async_max_concurrency
      )
    end

    # Create new config with updated refresh token
    def with_refresh_token(token)
      self.class.new(
        mode: @mode,
        api_url: @api_url,
        access_token: @access_token,
        refresh_token: token,
        ksef_token: @ksef_token,
        certificate_path: @certificate_path,
        encryption_key: @encryption_key,
        encrypted_key: @encrypted_key,
        identifier: @identifier,
        logger: @logger,
        async_max_concurrency: @async_max_concurrency
      )
    end

    # Create new config with updated KSEF token
    def with_ksef_token(token)
      self.class.new(
        mode: @mode,
        api_url: @api_url,
        access_token: @access_token,
        refresh_token: @refresh_token,
        ksef_token: token,
        certificate_path: @certificate_path,
        encryption_key: @encryption_key,
        encrypted_key: @encrypted_key,
        identifier: @identifier,
        logger: @logger,
        async_max_concurrency: @async_max_concurrency
      )
    end

    # Create new config with updated certificate path
    def with_certificate_path(path)
      self.class.new(
        mode: @mode,
        api_url: @api_url,
        access_token: @access_token,
        refresh_token: @refresh_token,
        ksef_token: @ksef_token,
        certificate_path: path,
        encryption_key: @encryption_key,
        encrypted_key: @encrypted_key,
        identifier: @identifier,
        logger: @logger,
        async_max_concurrency: @async_max_concurrency
      )
    end

    # Create new config with updated encryption key
    def with_encryption_key(key)
      self.class.new(
        mode: @mode,
        api_url: @api_url,
        access_token: @access_token,
        refresh_token: @refresh_token,
        ksef_token: @ksef_token,
        certificate_path: @certificate_path,
        encryption_key: key,
        encrypted_key: @encrypted_key,
        identifier: @identifier,
        logger: @logger,
        async_max_concurrency: @async_max_concurrency
      )
    end

    # Create new config with updated encrypted key
    def with_encrypted_key(key)
      self.class.new(
        mode: @mode,
        api_url: @api_url,
        access_token: @access_token,
        refresh_token: @refresh_token,
        ksef_token: @ksef_token,
        certificate_path: @certificate_path,
        encryption_key: @encryption_key,
        encrypted_key: key,
        identifier: @identifier,
        logger: @logger,
        async_max_concurrency: @async_max_concurrency
      )
    end

    # Create new config with updated identifier
    def with_identifier(identifier)
      self.class.new(
        mode: @mode,
        api_url: @api_url,
        access_token: @access_token,
        refresh_token: @refresh_token,
        ksef_token: @ksef_token,
        certificate_path: @certificate_path,
        encryption_key: @encryption_key,
        encrypted_key: @encrypted_key,
        identifier: identifier,
        logger: @logger,
        async_max_concurrency: @async_max_concurrency
      )
    end

    # Create new config with updated logger
    def with_logger(logger)
      self.class.new(
        mode: @mode,
        api_url: @api_url,
        access_token: @access_token,
        refresh_token: @refresh_token,
        ksef_token: @ksef_token,
        certificate_path: @certificate_path,
        encryption_key: @encryption_key,
        encrypted_key: @encrypted_key,
        identifier: @identifier,
        logger: logger,
        async_max_concurrency: @async_max_concurrency
      )
    end

    # Create new config with updated async max concurrency
    def with_async_max_concurrency(value)
      self.class.new(
        mode: @mode,
        api_url: @api_url,
        access_token: @access_token,
        refresh_token: @refresh_token,
        ksef_token: @ksef_token,
        certificate_path: @certificate_path,
        encryption_key: @encryption_key,
        encrypted_key: @encrypted_key,
        identifier: @identifier,
        logger: @logger,
        async_max_concurrency: value
      )
    end
  end
end
