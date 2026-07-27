# frozen_string_literal: true

class CompaniesController < ApplicationController
  def index
    @companies = Company.ordered.includes(:company_questions)
  end

  def show
    @company = Company.find_by_slug!(params[:slug])
    @questions = @company.company_questions.ordered
    @rounds = @questions.map(&:interview_round).compact.uniq
    @difficulties = @questions.map(&:difficulty).compact.uniq
  end
end
