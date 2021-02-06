# frozen_string_literal: true

class Itinerary < ApplicationRecord
  include GeoItinerary
  extend FriendlyId

  DAYNAME = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

  friendly_id :name, use: :slugged

  def name
    [start_address, end_address].join ' '
  end

  has_many :conversations, as: :conversable, dependent: :destroy

  belongs_to :user
  delegate :name, to: :user, prefix: true
  delegate :first_name, to: :user, prefix: true

  validates :description, length: { maximum: 1000 }, presence: true
  validates :num_people, numericality: { only_integer: true, greater_than: 0, less_than: 10 }, allow_blank: true
  validates :fuel_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 10_000 }
  validates :tolls, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 10_000 }
  validates :leave_date, timeliness: { on_or_after: -> { Time.current } }, on: :create
  validates :return_date, presence: true, if: -> { round_trip }

  validate :driver_is_female, if: -> { pink }
  validate :return_date_validator, if: -> { round_trip }

  def return_date_validator
    return unless return_date && return_date <= leave_date

    errors.add(:return_date,
               I18n.t('mongoid.errors.messages.after',
                      restriction: leave_date.strftime(I18n.t('validates_timeliness.error_value_formats.datetime'))))
  end

  def driver_is_female
    errors.add(:pink, :driver_must_be_female) unless user.female?
  end

  before_create do
    self.driver_gender = user.gender
    true
  end

  def title
    [start_address, end_address].join ' - '
  end

  def to_s
    title || id
  end
end
