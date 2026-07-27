# frozen_string_literal: true

class ProgressRecord < ApplicationRecord
  STATUSES = %w[started completed skipped].freeze

  validates :visitor_token, presence: true
  validates :record_type, presence: true
  validates :record_id, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :record_id, uniqueness: { scope: %i[visitor_token record_type] }

  scope :for_visitor, ->(token) { where(visitor_token: token) }
  scope :completed, -> { where(status: "completed") }
  scope :for_questions, -> { where(record_type: "Question") }

  def record
    record_type.constantize.find_by(id: record_id)
  end
end
