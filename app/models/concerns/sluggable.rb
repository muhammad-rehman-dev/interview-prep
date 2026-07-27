# frozen_string_literal: true

module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :ensure_slug, on: :create
    validates :slug, presence: true, uniqueness: true
  end

  class_methods do
    def find_by_slug!(slug)
      find_by!(slug: slug)
    end
  end

  def to_param
    slug
  end

  private

  def ensure_slug
    return if slug.present?
    return unless respond_to?(:title) || respond_to?(:name)

    base = (try(:title) || try(:name)).to_s.parameterize
    base = "item" if base.blank?
    candidate = base
    counter = 1

    while self.class.exists?(slug: candidate)
      candidate = "#{base}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end
end
