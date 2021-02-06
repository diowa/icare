# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteUserJob do
  describe '#perform' do
    subject(:perform) { described_class.new.perform(user_uid) }

    let(:user_uid) { '123456' }

    before do
      allow(AuthorizationService).to receive(:delete_user).with(user_uid)
    end

    it 'deletes user through authorization service' do
      perform

      expect(AuthorizationService).to have_received(:delete_user).with(user_uid)
    end
  end
end
