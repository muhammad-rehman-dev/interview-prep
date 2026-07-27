# frozen_string_literal: true

class QuestionRepository
  def self.all_with_associations
    Question.includes(:category, :tags).ordered
  end

  def self.find_by_slug!(slug)
    Question.includes(:category, :tags).find_by!(slug: slug)
  end

  def self.related_to(question, limit: 5)
    related = question.related_questions.limit(limit)
    return related if related.exists?

    Question.where(category_id: question.category_id)
            .where.not(id: question.id)
            .includes(:category, :tags)
            .ordered
            .limit(limit)
  end

  def self.filter_options
    {
      difficulties: Question.where.not(difficulty: [nil, ""]).distinct.order(:difficulty).pluck(:difficulty),
      interview_types: Question.where.not(interview_type: [nil, ""]).distinct.order(:interview_type).pluck(:interview_type),
      companies: Question.where.not(company: [nil, ""]).distinct.order(:company).pluck(:company),
      sources: Question.where.not(source: [nil, ""]).distinct.order(:source).pluck(:source),
      categories: Category.ordered
    }
  end

  def self.continue_learning(visitor_token, limit: 5)
    completed_ids = ProgressRecord.for_visitor(visitor_token).for_questions.completed.pluck(:record_id)
    Question.includes(:category)
            .where.not(id: completed_ids)
            .ordered
            .limit(limit)
  end
end
