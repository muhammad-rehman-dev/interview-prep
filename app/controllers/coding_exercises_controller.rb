# frozen_string_literal: true

class CodingExercisesController < ApplicationController
  def index
    @exercises = CodingExercise.ordered
    @exercises = @exercises.by_difficulty(params[:difficulty]) if params[:difficulty].present?
    @exercises = @exercises.by_category(params[:category]) if params[:category].present?
    @difficulties = CodingExercise::DIFFICULTIES
    @categories = CodingExercise.distinct.order(:category).pluck(:category).compact_blank
  end

  def show
    @exercise = CodingExercise.find_by!(slug: params[:slug])
  end
end
