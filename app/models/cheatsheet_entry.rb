# frozen_string_literal: true

class CheatsheetEntry < ApplicationRecord
  include Sluggable

  validates :title, presence: true

  scope :ordered, -> { order(:position, :title) }
  scope :by_category, ->(value) { where(category: value) if value.present? }

  def self.categories
    distinct.order(:category).pluck(:category).compact_blank
  end
end
