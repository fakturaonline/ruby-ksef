# frozen_string_literal: true

require "spec_helper"

RSpec.describe KSEF::Requests::Testdata::AttachmentGrantHandler do
  let(:http_client) { instance_double(KSEF::HttpClient::Client) }
  let(:handler) { described_class.new(http_client) }

  describe "#call" do
    it "sends POST request to testdata/attachment" do
      attachment_data = {
        nip: "1234567890",
        attachment: {
          filename: "test.pdf",
          content: "base64content"
        }
      }

      response = double(json: { "attachmentId" => "att_123" })

      expect(http_client).to receive(:post).with("testdata/attachment", body: attachment_data).and_return(response)

      result = handler.call(attachment_data: attachment_data)
      expect(result).to eq({ "attachmentId" => "att_123" })
    end
  end
end
