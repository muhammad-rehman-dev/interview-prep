# frozen_string_literal: true

class MockInterview < ApplicationRecord
  include Sluggable

  DIFFICULTIES = %w[easy medium hard].freeze

  has_many :mock_interview_items, -> { order(:position) }, dependent: :destroy, inverse_of: :mock_interview

  validates :title, presence: true
  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_blank: true

  scope :ordered, -> { order(:position, :title) }
end
