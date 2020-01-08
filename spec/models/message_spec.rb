# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message do
  describe '#unread?' do
    subject { message.unread? }

    let(:message) { described_class.new }

    context 'when read_at is nil' do
      it { is_expected.to be true }
    end

    context 'when read_at is not nil' do
      let(:message) { described_class.new read_at: Time.current }

      it { is_expected.to be false }
    end
  end
end
