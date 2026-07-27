# frozen_string_literal: true

class QuizController < ApplicationController
  def show
    @questions = load_quiz_questions
    @submitted = false
    @score = nil
    @answers = {}
  end

  def create
    @questions = QuizQuestion.where(id: params[:question_ids])
    @answers = params.fetch(:answers, {}).to_unsafe_h
    @submitted = true
    @score = @questions.count { |q| @answers[q.id.to_s].to_i == q.correct_index }
    @total = @questions.size
    render :show
  end

  private

  def load_quiz_questions
    QuizQuestion.random_batch(10).to_a
  end
end
