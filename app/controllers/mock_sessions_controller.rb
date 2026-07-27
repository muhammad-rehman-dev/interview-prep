# frozen_string_literal: true

class MockSessionsController < ApplicationController
  def show
    @mode = params[:mode].presence || session[:mock_mode] || "random"
    session[:mock_mode] = @mode
    @question = pick_question(@mode)
    @duration = (@question&.estimated_minutes || 5) * 60
    @companies = Question.where.not(company: [nil, ""]).distinct.order(:company).pluck(:company)
    @difficulties = Question::DIFFICULTIES
    @selected_company = params[:company].presence
    @selected_difficulty = params[:difficulty].presence || "medium"
  end

  def update
    session[:mock_mode] = params[:mode] if params[:mode].present?
    session[:mock_index] = session.fetch(:mock_index, 0) + 1
    redirect_to mock_session_path(
      mode: session[:mock_mode],
      company: params[:company],
      difficulty: params[:difficulty],
      reveal: false
    )
  end

  private

  def pick_question(mode)
    scope = Question.includes(:category, :tags)
    scope = case mode
            when "company"
              company = params[:company].presence || Question.where.not(company: [nil, ""]).distinct.order(:company).limit(1).pick(:company)
              company.present? ? scope.by_company(company) : scope
            when "difficulty"
              difficulty = params[:difficulty].presence || "medium"
              scope.by_difficulty(difficulty)
            else
              scope
            end

    ids = scope.pluck(:id)
    return nil if ids.empty?

    Question.includes(:category, :tags).find(ids.sample)
  end
end
