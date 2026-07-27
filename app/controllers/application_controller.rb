# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include VisitorToken

  private

  def redirect_with_notice(path, notice:)
    redirect_to path, notice: notice
  end
end
