# frozen_string_literal: true

class Feedback < ApplicationRecord
  enum category: {
    bug:  'bug',
    idea: 'idea'
  }

  enum status: {
    normal:         'normal',
    fixed:          'fixed',
    in_progress:    'in_progress',
    not_applicable: 'not_applicable'
  }

  belongs_to :user
  delegate :name, to: :user, prefix: true, allow_nil: true

  validates :category, presence: true, inclusion: { in: categories.values }
  validates :status, presence: true, inclusion: { in: statuses.values }
  validates :message, presence: true
end
