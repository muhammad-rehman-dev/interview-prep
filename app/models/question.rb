# frozen_string_literal: true

class Question < ApplicationRecord
  include Sluggable

  DIFFICULTIES = %w[basic easy medium hard].freeze
  INTERVIEW_TYPES = %w[theory practical architecture coding behavioral system_design database].freeze

  belongs_to :category
  has_many :question_tags, dependent: :destroy
  has_many :tags, through: :question_tags
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy

  validates :title, presence: true
  validates :difficulty, inclusion: { in: DIFFICULTIES }, allow_blank: true
  validates :interview_type, inclusion: { in: INTERVIEW_TYPES }, allow_blank: true

  scope :ordered, -> { order(frequency_score: :desc, title: :asc) }
  scope :by_difficulty, ->(value) { where(difficulty: value) if value.present? }
  scope :by_interview_type, ->(value) { where(interview_type: value) if value.present? }
  scope :by_company, ->(value) { where(company: value) if value.present? }
  scope :by_source, ->(value) { where(source: value) if value.present? }
  scope :by_category_slug, lambda { |slug|
    joins(:category).where(categories: { slug: slug }) if slug.present?
  }
  scope :search, lambda { |query|
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query.to_s.strip)}%"
    where(
      "questions.title LIKE :q OR questions.body LIKE :q OR questions.answer LIKE :q OR questions.tags_cache LIKE :q",
      q: pattern
    )
  }

  def follow_up_list
    parse_text_list(follow_ups)
  end

  def follow_ups=(value)
    super(normalize_text_list(value))
  end

  def related_questions
    slugs = related_slug_list
    return Question.none if slugs.empty?

    Question.where(slug: slugs).includes(:category, :tags)
  end

  def related_slug_list
    return [] if related_slugs.blank?

    related_slugs.to_s.split(/[\n,]+/).map(&:strip).reject(&:blank?)
  end

  def tag_names
    tags.map(&:name).presence || tags_cache.to_s.split(",").map(&:strip).reject(&:blank?)
  end

  private

  def parse_text_list(raw)
    return [] if raw.blank?

    text = raw.to_s.strip
    if text.start_with?("[")
      parsed = JSON.parse(text)
      return Array(parsed).map { |item| item.to_s.strip }.reject(&:blank?)
    end

    text.split(/\r?\n+/).map(&:strip).reject(&:blank?)
  rescue JSON::ParserError
    text.split(/\r?\n+/).map(&:strip).reject(&:blank?)
  end

  def normalize_text_list(value)
    case value
    when nil
      nil
    when Array
      value.map { |item| item.to_s.strip }.reject(&:blank?).join("\n")
    else
      value.to_s
    end
  end
end
