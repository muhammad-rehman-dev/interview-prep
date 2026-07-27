# frozen_string_literal: true

class CategoriesController < ApplicationController
  def index
    @categories = Category.ordered.includes(:questions)
  end

  def show
    @category = Category.find_by!(slug: params[:slug])
    @questions = @category.questions.includes(:tags).ordered
    completed_ids = progress_tracker.completed_question_ids
    @completed_count = @questions.count { |q| completed_ids.include?(q.id) }
  end
end
