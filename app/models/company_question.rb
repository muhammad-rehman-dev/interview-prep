# frozen_string_literal: true

class CompanyQuestion < ApplicationRecord
  DIFFICULTIES = %w[basic easy medium hard].freeze
  ROUNDS = %w[
    screening
    technical
    take_home
    system_design
    architecture
    coding
    behavioral
    ai_first
  ].freeze

  belongs_to :company

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: { scope: :company_id }
  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_blank: true
  validates :interview_round, inclusion: { in: ROUNDS }, allow_blank: true

  before_validation :ensure_slug, on: :create

  scope :ordered, -> { order(position: :asc, frequency_score: :desc, title: :asc) }
  scope :by_difficulty, ->(value) { where(difficulty: value) if value.present? }
  scope :by_round, ->(value) { where(interview_round: value) if value.present? }

  def to_param
    slug
  end

  def follow_up_list
    return [] if follow_ups.blank?

    raw = follow_ups.to_s.strip
    if raw.start_with?("[")
      JSON.parse(raw)
    else
      raw.split(/\n+/).map(&:strip).reject(&:blank?)
    end
  rescue JSON::ParserError
    follow_ups.to_s.split(/\n+/).map(&:strip).reject(&:blank?)
  end

  def tag_names
    tags_cache.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  private

  def ensure_slug
    return if slug.present?

    base = title.to_s.parameterize
    base = "question" if base.blank?
    candidate = base
    counter = 1

    while company && company.company_questions.where(slug: candidate).where.not(id: id).exists?
      candidate = "#{base}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end
end
