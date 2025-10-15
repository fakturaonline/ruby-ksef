# frozen_string_literal: true

# Example Rails integration for KSEF client
#
# This example shows how to integrate KSEF client into a Rails application
# with proper credential management and background job processing.

# config/initializers/ksef.rb
# ============================================
#
# KSEF.configure do |config|
#   config.mode = ENV['KSEF_MODE']&.to_sym || :test
#   config.certificate_path = ENV['KSEF_CERTIFICATE_PATH']
#   config.certificate_passphrase = ENV['KSEF_CERTIFICATE_PASSPHRASE']
#   config.default_nip = ENV['KSEF_DEFAULT_NIP']
#   config.encryption_key = ENV['KSEF_ENCRYPTION_KEY']
#   config.encryption_iv = ENV['KSEF_ENCRYPTION_IV']
# end

# app/models/ksef_credential.rb
# ============================================
class KsefCredential < ApplicationRecord
  # Table: ksef_credentials
  # - nip:string
  # - access_token:text
  # - access_token_expires_at:datetime
  # - refresh_token:text
  # - refresh_token_expires_at:datetime
  # - encryption_key:text (encrypted)
  # - encryption_iv:text (encrypted)

  encrypts :access_token, :refresh_token, :encryption_key, :encryption_iv

  def client
    @client ||= KSEF.build do
      mode Rails.env.production? ? :production : :test
      identifier nip

      if access_token.present?
        access_token access_token, expires_at: access_token_expires_at
        refresh_token refresh_token, expires_at: refresh_token_expires_at if refresh_token.present?
      end

      if encryption_key.present?
        encryption_key(
          Base64.decode64(encryption_key),
          Base64.decode64(encryption_iv)
        )
      end

      logger Rails.logger
    end
  end

  def save_tokens!(client)
    update!(
      access_token: client.access_token.token,
      access_token_expires_at: client.access_token.expires_at,
      refresh_token: client.refresh_token&.token,
      refresh_token_expires_at: client.refresh_token&.expires_at
    )
  end

  def generate_encryption_key!
    key = KSEF::ValueObjects::EncryptionKey.random
    update!(
      encryption_key: Base64.strict_encode64(key.key),
      encryption_iv: Base64.strict_encode64(key.iv)
    )
  end
end

# app/models/invoice.rb
# ============================================
class Invoice < ApplicationRecord
  # Table: invoices
  # - number:string
  # - ksef_number:string
  # - ksef_reference_number:string
  # - ksef_status:string
  # - xml_content:text
  # - sent_at:datetime

  belongs_to :company

  enum :ksef_status, {
    draft: "draft",
    sending: "sending",
    processing: "processing",
    accepted: "accepted",
    rejected: "rejected"
  }

  def send_to_ksef!
    return if ksef_number.present?

    # Queue background job
    KsefSendInvoiceJob.perform_later(id)
  end

  def ksef_client
    company.ksef_credential.client
  end
end

# app/jobs/ksef_send_invoice_job.rb
# ============================================
class KsefSendInvoiceJob < ApplicationJob
  queue_as :default
  retry_on KSEF::NetworkError, wait: :exponentially_longer, attempts: 5

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)
    client = invoice.ksef_client

    invoice.update!(ksef_status: :sending)

    # Calculate hash
    invoice_hash = Digest::SHA256.base64digest(invoice.xml_content)

    # Send invoice
    response = client.sessions.send_online(
      invoice_hash: invoice_hash,
      invoice_payload: Base64.strict_encode64(invoice.xml_content)
    )

    reference_number = response["referenceNumber"]
    invoice.update!(
      ksef_reference_number: reference_number,
      ksef_status: :processing,
      sent_at: Time.current
    )

    # Queue status check job
    KsefCheckStatusJob.set(wait: 10.seconds).perform_later(invoice_id)
  rescue KSEF::ApiError => e
    invoice.update!(ksef_status: :rejected)
    Rails.logger.error("KSEF API Error: #{e.message}")
    raise
  end
end

# app/jobs/ksef_check_status_job.rb
# ============================================
class KsefCheckStatusJob < ApplicationJob
  queue_as :default

  def perform(invoice_id, attempt = 1)
    invoice = Invoice.find(invoice_id)
    return if invoice.ksef_status == "accepted"

    client = invoice.ksef_client
    status = client.sessions.status(invoice.ksef_reference_number)

    case status["status"]["code"]
    when 200
      # Success
      invoice.update!(
        ksef_number: status["ksefNumber"],
        ksef_status: :accepted
      )

      # Send notification
      InvoiceMailer.ksef_accepted(invoice).deliver_later

    when 400..599
      # Error
      invoice.update!(ksef_status: :rejected)
      Rails.logger.error("KSEF rejected invoice: #{status["status"]["description"]}")

    else
      # Still processing, retry
      raise "Max attempts reached" if attempt >= 12 # 2 minutes

      KsefCheckStatusJob.set(wait: 10.seconds).perform_later(invoice_id, attempt + 1)
    end
  end
end

# app/jobs/ksef_download_invoice_job.rb
# ============================================
class KsefDownloadInvoiceJob < ApplicationJob
  queue_as :default

  def perform(ksef_number, company_id)
    company = Company.find(company_id)
    client = company.ksef_credential.client

    # Download encrypted invoice
    encrypted = client.invoices.download(ksef_number)

    # Decrypt
    decryptor = KSEF::Actions::DecryptDocument.new(client.encryption_key)
    xml_content = decryptor.call(encrypted)

    # Save to database
    Invoice.create!(
      company: company,
      ksef_number: ksef_number,
      xml_content: xml_content,
      ksef_status: :accepted
    )
  end
end

# app/controllers/ksef/invoices_controller.rb
# ============================================
module Ksef
  class InvoicesController < ApplicationController
    before_action :authenticate_user!

    def send_invoice
      invoice = current_user.company.invoices.find(params[:id])
      invoice.send_to_ksef!

      redirect_to invoice, notice: "Invoice queued for KSEF submission"
    end

    def query
      client = current_user.company.ksef_credential.client

      @results = client.invoices.query(
        from_date: params[:from_date],
        to_date: params[:to_date],
        invoice_type: params[:type] || "sent"
      )
    end

    def download
      KsefDownloadInvoiceJob.perform_later(params[:ksef_number], current_user.company_id)

      redirect_to root_path, notice: "Invoice download queued"
    end
  end
end

# app/services/ksef_auth_service.rb
# ============================================
class KsefAuthService
  def initialize(company)
    @company = company
    @credential = company.ksef_credential || company.create_ksef_credential!(nip: company.nip)
  end

  def authenticate_with_certificate(certificate_path, passphrase)
    client = KSEF.build do
      mode Rails.env.production? ? :production : :test
      certificate_path certificate_path, passphrase
      identifier @credential.nip
      random_encryption_key
    end

    # Save tokens
    @credential.save_tokens!(client)

    # Save encryption key
    @credential.update!(
      encryption_key: Base64.strict_encode64(client.encryption_key.key),
      encryption_iv: Base64.strict_encode64(client.encryption_key.iv)
    )

    client
  end

  def authenticate_with_ksef_token(ksef_token)
    client = KSEF.build do
      mode Rails.env.production? ? :production : :test
      ksef_token ksef_token
      identifier @credential.nip
    end

    @credential.save_tokens!(client)
    client
  end
end

# config/routes.rb
# ============================================
# Rails.application.routes.draw do
#   namespace :ksef do
#     resources :invoices, only: [:index] do
#       member do
#         post :send_invoice
#       end
#
#       collection do
#         get :query
#         post :download
#       end
#     end
#   end
# end

# Usage in Rails console:
# ============================================
#
# # Setup credentials
# company = Company.first
# credential = company.create_ksef_credential!(nip: "1234567890")
# service = KsefAuthService.new(company)
# service.authenticate_with_certificate("/path/to/cert.p12", "passphrase")
#
# # Send invoice
# invoice = company.invoices.create!(number: "INV-001", xml_content: "...")
# invoice.send_to_ksef!
#
# # Query invoices
# client = company.ksef_credential.client
# results = client.invoices.query(from_date: "2025-01-01", to_date: "2025-01-31")
