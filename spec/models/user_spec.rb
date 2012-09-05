require 'spec_helper'

describe User do
  describe 'class'do
    it 'should do the magic' do
      expect(User).to have_and_belong_to_many :conversations

      expect(User).to have_many :itineraries
      expect(User).to have_many :feedbacks

      expect(User).to embed_many :notifications
      expect(User).to embed_many :references

      expect(User).to validate_inclusion_of :gender
      expect(User).to validate_inclusion_of :nationality
      expect(User).to validate_inclusion_of :time_zone
      expect(User).to validate_numericality_of(:vehicle_avg_consumption).greater_than(0).less_than(10)
      #expect(User).to validate_numericality_of(:access_level).only_integer(true).greater_than_or_equal_to(0).less_than_or_equal_to(10)
    end
  end

  describe 'object' do
    before do
      load "#{Rails.root}/db/seeds.rb"
    end

    it 'should set the languages correctly' do
    end

  end
end
