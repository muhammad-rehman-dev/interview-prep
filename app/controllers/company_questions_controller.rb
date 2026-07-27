# frozen_string_literal: true

class CompanyQuestionsController < ApplicationController
  def show
    @company = Company.find_by_slug!(params[:company_slug])
    @question = @company.company_questions.find_by!(slug: params[:slug])
    @related = @company.company_questions
                       .where.not(id: @question.id)
                       .where(interview_round: @question.interview_round)
                       .ordered
                       .limit(5)
  end
end
