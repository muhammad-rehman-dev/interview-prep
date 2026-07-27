# frozen_string_literal: true

class MockInterviewItem < ApplicationRecord
  belongs_to :mock_interview

  validates :section, presence: true
  validates :prompt, presence: true

  scope :ordered, -> { order(:position) }
end
