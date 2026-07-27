# frozen_string_literal: true

module VisitorToken
  extend ActiveSupport::Concern

  VISITOR_COOKIE = :visitor_token

  included do
    helper_method :visitor_token, :progress_tracker
  end

  def visitor_token
    cookies.permanent.signed[VISITOR_COOKIE] ||= SecureRandom.uuid
  end

  def progress_tracker
    @progress_tracker ||= ProgressTracker.new(visitor_token)
  end
end
