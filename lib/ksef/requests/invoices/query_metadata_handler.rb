# frozen_string_literal: true

module KSEF
  module Requests
    module Invoices
      # Handler for querying invoice metadata
      class QueryMetadataHandler
        def initialize(http_client)
          @http_client = http_client
        end

        # Query invoice metadata
        # @param filters [Hash] Query filters
        # @option filters [String] :subject_type Subject type (subject1, subject2, subject3)
        # @option filters [Hash] :date_range Date range with :from and :to
        # @option filters [String] :ksef_number Optional KSEF number
        # @option filters [String] :invoice_number Optional invoice number
        # @option filters [Hash] :amount Optional amount range
        # @option filters [String] :seller_nip Optional seller NIP
        # @option filters [Hash] :buyer_identifier Optional buyer identifier
        # @option filters [Array<String>] :currency_codes Optional currency codes
        # @option filters [String] :invoicing_mode Optional invoicing mode
        # @option filters [Boolean] :is_self_invoicing Optional self-invoicing flag
        # @option filters [String] :form_type Optional form type
        # @option filters [Array<String>] :invoice_types Optional invoice types
        # @option filters [Boolean] :has_attachment Optional attachment flag
        # @param page_size [Integer, nil] Optional page size
        # @param page_offset [Integer, nil] Optional page offset
        # @return [Hash] Query results with invoice metadata
        def call(filters:, page_size: nil, page_offset: nil)
          params = {}
          params[:pageSize] = page_size if page_size
          params[:pageOffset] = page_offset if page_offset

          body = prepare_filters(filters)

          response = @http_client.post("invoices/query/metadata", body: body, params: params)
          response.json
        end

        private

        def prepare_filters(filters)
          result = {}

          result[:subjectType] = filters[:subject_type] if filters[:subject_type]
          result[:dateRange] = filters[:date_range] if filters[:date_range]
          result[:ksefNumber] = filters[:ksef_number] if filters[:ksef_number]
          result[:invoiceNumber] = filters[:invoice_number] if filters[:invoice_number]
          result[:amount] = filters[:amount] if filters[:amount]
          result[:sellerNip] = filters[:seller_nip] if filters[:seller_nip]
          result[:buyerIdentifier] = filters[:buyer_identifier] if filters[:buyer_identifier]
          result[:currencyCodes] = filters[:currency_codes] if filters[:currency_codes]
          result[:invoicingMode] = filters[:invoicing_mode] if filters[:invoicing_mode]
          result[:isSelfInvoicing] = filters[:is_self_invoicing] if filters.key?(:is_self_invoicing)
          result[:formType] = filters[:form_type] if filters[:form_type]
          result[:invoiceTypes] = filters[:invoice_types] if filters[:invoice_types]
          result[:hasAttachment] = filters[:has_attachment] if filters.key?(:has_attachment)

          result
        end
      end
    end
  end
end
