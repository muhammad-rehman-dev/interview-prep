# frozen_string_literal: true

class CodingExercise < ApplicationRecord
  include Sluggable

  DIFFICULTIES = %w[easy medium hard].freeze

  validates :title, presence: true
  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_blank: true

  scope :ordered, -> { order(:position, :title) }
  scope :by_difficulty, ->(value) { where(difficulty: value) if value.present? }
  scope :by_category, ->(value) { where(category: value) if value.present? }
end
