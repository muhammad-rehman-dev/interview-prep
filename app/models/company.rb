# frozen_string_literal: true

class Company < ApplicationRecord
  include Sluggable

  has_many :company_questions, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(position: :asc, name: :asc) }

  def question_count
    company_questions.size
  end
end
