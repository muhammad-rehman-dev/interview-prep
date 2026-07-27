# frozen_string_literal: true

class FlashcardsController < ApplicationController
  def show
    @question = current_flashcard
  end

  def next
    session[:flashcard_ids] = reshuffled_ids if session[:flashcard_ids].blank?
    ids = session[:flashcard_ids] || []
    session[:flashcard_index] = ((session[:flashcard_index] || 0) + 1) % [ids.size, 1].max
    redirect_to flashcards_path
  end

  private

  def current_flashcard
    ids = session[:flashcard_ids]
    if ids.blank?
      ids = reshuffled_ids
      session[:flashcard_ids] = ids
      session[:flashcard_index] = 0
    end

    return nil if ids.blank?

    index = session[:flashcard_index].to_i % ids.size
    Question.includes(:category).find_by(id: ids[index])
  end

  def reshuffled_ids
    Question.order(Arel.sql("RANDOM()")).limit(50).pluck(:id)
  end
end
