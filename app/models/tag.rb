# frozen_string_literal: true

class Tag < ApplicationRecord
  include Sluggable

  has_many :question_tags, dependent: :destroy
  has_many :questions, through: :question_tags

  validates :name, presence: true
end
