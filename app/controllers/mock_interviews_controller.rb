# frozen_string_literal: true

class MockInterviewsController < ApplicationController
  def index
    @mock_interviews = MockInterview.ordered.includes(:mock_interview_items)
  end

  def show
    @mock_interview = MockInterview.includes(:mock_interview_items).find_by!(slug: params[:slug])
  end
end
