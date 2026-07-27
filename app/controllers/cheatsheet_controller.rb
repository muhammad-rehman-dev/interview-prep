# frozen_string_literal: true

class CheatsheetController < ApplicationController
  def index
    @entries = CheatsheetEntry.ordered
    @grouped = @entries.group_by { |e| e.category.presence || "General" }
  end

  def show
    @entry = CheatsheetEntry.find_by!(slug: params[:slug])
    @related = CheatsheetEntry.by_category(@entry.category).where.not(id: @entry.id).ordered.limit(6)
  end
end
