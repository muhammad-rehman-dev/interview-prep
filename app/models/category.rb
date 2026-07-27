# frozen_string_literal: true

class Category < ApplicationRecord
  include Sluggable

  has_many :questions, dependent: :restrict_with_exception

  validates :name, presence: true

  scope :ordered, -> { order(:position, :name) }

  def question_count
    questions.count
  end

  def progress_percent(completed_count)
    return 0 if target_count.to_i.zero?

    [[(completed_count.to_f / target_count) * 100, 100].min, 0].max.round
  end
end
