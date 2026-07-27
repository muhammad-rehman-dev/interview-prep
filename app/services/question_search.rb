# frozen_string_literal: true

class QuestionSearch
  def initialize(params:, visitor_token: nil)
    @params = params.to_h.with_indifferent_access
    @visitor_token = visitor_token
  end

  def call
    scope = Question.includes(:category, :tags).ordered
    scope = scope.search(@params[:q])
    scope = scope.by_difficulty(@params[:difficulty])
    scope = scope.by_interview_type(@params[:interview_type])
    scope = scope.by_company(@params[:company])
    scope = scope.by_source(@params[:source])
    scope = scope.by_category_slug(@params[:category])
    scope = apply_favorite(scope)
    scope = apply_completed(scope)
    scope
  end

  private

  def apply_favorite(scope)
    return scope unless truthy?(@params[:favorite])
    return scope.none if @visitor_token.blank?

    ids = Bookmark.for_visitor(@visitor_token).questions.pluck(:bookmarkable_id)
    scope.where(id: ids)
  end

  def apply_completed(scope)
    return scope unless truthy?(@params[:completed])
    return scope.none if @visitor_token.blank?

    ids = ProgressRecord.for_visitor(@visitor_token).for_questions.completed.pluck(:record_id)
    scope.where(id: ids)
  end

  def truthy?(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end
end
