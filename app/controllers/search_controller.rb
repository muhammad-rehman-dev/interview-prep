# frozen_string_literal: true

class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @questions = Question.none
    @exercises = CodingExercise.none
    @mocks = MockInterview.none
    @cheatsheets = CheatsheetEntry.none

    return if @query.blank?

    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(@query)}%"
    @questions = Question.includes(:category).search(@query).limit(20)
    @exercises = CodingExercise.where("title LIKE :q OR problem LIKE :q", q: pattern).ordered.limit(10)
    @mocks = MockInterview.where("title LIKE :q OR introduction LIKE :q", q: pattern).ordered.limit(10)
    @cheatsheets = CheatsheetEntry.where("title LIKE :q OR rails_concept LIKE :q", q: pattern).ordered.limit(10)
  end
end
