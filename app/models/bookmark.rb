# frozen_string_literal: true

class Bookmark < ApplicationRecord
  belongs_to :bookmarkable, polymorphic: true

  validates :visitor_token, presence: true
  validates :bookmarkable_id, uniqueness: { scope: %i[visitor_token bookmarkable_type] }

  scope :for_visitor, ->(token) { where(visitor_token: token) }
  scope :questions, -> { where(bookmarkable_type: "Question") }
end
