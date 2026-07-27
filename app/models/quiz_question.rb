# frozen_string_literal: true

class QuizQuestion < ApplicationRecord
  DIFFICULTIES = %w[easy medium hard].freeze

  serialize :options, coder: JSON

  validates :prompt, presence: true
  validates :correct_index, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_blank: true
  validate :options_must_be_array_of_strings
  validate :correct_index_within_options

  scope :by_category, ->(value) { where(category: value) if value.present? }
  scope :by_difficulty, ->(value) { where(difficulty: value) if value.present? }
  scope :random_batch, ->(limit = 10) { order(Arel.sql("RANDOM()")).limit(limit) }

  def option_list
    Array(options)
  end

  def correct_option
    option_list[correct_index]
  end

  private

  def options_must_be_array_of_strings
    unless options.is_a?(Array)
      errors.add(:options, "must be an array")
      return
    end

    return if options.all? { |option| option.is_a?(String) }

    errors.add(:options, "must be an array of strings")
  end

  def correct_index_within_options
    return unless options.is_a?(Array)
    return if correct_index.blank?
    return if correct_index >= 0 && correct_index < options.length

    errors.add(:correct_index, "must be a valid index into options")
  end
end
