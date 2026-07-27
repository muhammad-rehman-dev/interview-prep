# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @stats = progress_tracker.stats
    @category_progress = progress_tracker.category_progress
    @continue_learning = QuestionRepository.continue_learning(visitor_token)
    @recent = progress_tracker.recent_completed
  end
end
