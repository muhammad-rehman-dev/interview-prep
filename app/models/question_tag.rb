# frozen_string_literal: true

class QuestionTag < ApplicationRecord
  belongs_to :question
  belongs_to :tag

  validates :question_id, uniqueness: { scope: :tag_id }
end
