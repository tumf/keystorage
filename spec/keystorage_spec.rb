# coding: utf-8
require 'keystorage'

describe Keystorage do
  let(:test_class) { Struct.new(:a){ include Keystorage } }
  subject { test_class.new  }

  describe "#render" do

    context "Unknown format ':unknown' given" do
      let(:format) { :unknown }
      let(:string) { SecureRandom.urlsafe_base64(nil, false) }
      it "raises Keystorage::FormatNotSupport" do
        expect { subject.render(string,format) }.to raise_error(Keystorage::FormatNotSupport)
      end
    end

  end
end
