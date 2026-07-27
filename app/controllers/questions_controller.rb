# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :set_question, only: %i[show toggle_bookmark toggle_complete]

  PER_PAGE = 25

  def index
    @filters = QuestionRepository.filter_options
    scope = QuestionSearch.new(params: filter_params, visitor_token: visitor_token).call
    @total_count = scope.except(:select).count
    @page = [params[:page].to_i, 1].max
    @per_page = PER_PAGE
    @total_pages = [(@total_count.to_f / @per_page).ceil, 1].max
    @page = @total_pages if @page > @total_pages
    @questions = scope.offset((@page - 1) * @per_page).limit(@per_page)
    @completed_ids = progress_tracker.completed_question_ids
    @bookmarked_ids = progress_tracker.bookmarked_question_ids
  end

  def show
    @related = QuestionRepository.related_to(@question)
    @bookmarked = progress_tracker.bookmarked?(@question)
    @completed = progress_tracker.completed?(@question)
  end

  def toggle_bookmark
    bookmarked = progress_tracker.toggle_bookmark(@question)
    redirect_back fallback_location: question_path(@question),
                  notice: bookmarked ? "Bookmarked." : "Bookmark removed."
  end

  def toggle_complete
    completed = progress_tracker.toggle_complete(@question)
    redirect_back fallback_location: question_path(@question),
                  notice: completed ? "Marked complete." : "Marked incomplete."
  end

  private

  def set_question
    @question = QuestionRepository.find_by_slug!(params[:slug])
  end

  def filter_params
    params.permit(:q, :difficulty, :interview_type, :company, :source, :category, :favorite, :completed, :page)
  end
end
