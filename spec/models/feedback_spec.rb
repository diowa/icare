# frozen_string_literal: true
require 'spec_helper'

describe Feedback do
  describe '#fixed' do
    context 'when the status of feedback is fixed' do
      it 'returns true' do
        fixed_feedback = create :feedback, status: 'fixed'

        expect(fixed_feedback.fixed?).to be true
      end
    end

    context 'when the status of feedback is not fixed' do
      it 'returns false' do
        open_feedback = create :feedback

        expect(open_feedback.fixed?).to be false
      end
    end
  end
end
