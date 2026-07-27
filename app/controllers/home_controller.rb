# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @stats = {
      questions: Question.count,
      categories: Category.count,
      exercises: CodingExercise.count,
      mocks: MockInterview.count
    }
  end
end
