# frozen_string_literal: true

class ProgressTracker
  def initialize(visitor_token)
    @visitor_token = visitor_token
  end

  def mark_complete(record)
    progress = find_or_initialize_progress(record)
    progress.status = "completed"
    progress.save!
    progress
  end

  def toggle_complete(record)
    progress = find_or_initialize_progress(record)
    if progress.persisted? && progress.status == "completed"
      progress.destroy!
      false
    else
      progress.status = "completed"
      progress.save!
      true
    end
  end

  def toggle_bookmark(bookmarkable)
    bookmark = Bookmark.find_by(
      visitor_token: @visitor_token,
      bookmarkable: bookmarkable
    )

    if bookmark
      bookmark.destroy!
      decrement_bookmark_count(bookmarkable)
      false
    else
      Bookmark.create!(visitor_token: @visitor_token, bookmarkable: bookmarkable)
      increment_bookmark_count(bookmarkable)
      true
    end
  end

  def bookmarked?(bookmarkable)
    Bookmark.exists?(
      visitor_token: @visitor_token,
      bookmarkable: bookmarkable
    )
  end

  def completed?(record)
    ProgressRecord.exists?(
      visitor_token: @visitor_token,
      record_type: record.class.name,
      record_id: record.id,
      status: "completed"
    )
  end

  def completed_question_ids
    ProgressRecord.for_visitor(@visitor_token).for_questions.completed.pluck(:record_id)
  end

  def bookmarked_question_ids
    Bookmark.for_visitor(@visitor_token).questions.pluck(:bookmarkable_id)
  end

  def stats
    completed_ids = completed_question_ids
    {
      questions_completed: completed_ids.size,
      questions_total: Question.count,
      bookmarks: Bookmark.for_visitor(@visitor_token).count,
      categories_started: Question.where(id: completed_ids).distinct.count(:category_id),
      coding_exercises: CodingExercise.count,
      mock_interviews: MockInterview.count
    }
  end

  def category_progress
    completed_ids = completed_question_ids
    Category.ordered.map do |category|
      completed = category.questions.where(id: completed_ids).count
      {
        category: category,
        completed: completed,
        total: category.questions.count,
        target: category.target_count,
        percent: category.progress_percent(completed)
      }
    end
  end

  def recent_completed(limit: 5)
    ProgressRecord.for_visitor(@visitor_token)
                  .for_questions
                  .completed
                  .order(updated_at: :desc)
                  .limit(limit)
                  .filter_map(&:record)
  end

  private

  def find_or_initialize_progress(record)
    ProgressRecord.find_or_initialize_by(
      visitor_token: @visitor_token,
      record_type: record.class.name,
      record_id: record.id
    )
  end

  def increment_bookmark_count(bookmarkable)
    return unless bookmarkable.has_attribute?(:bookmarked_count)

    bookmarkable.increment!(:bookmarked_count)
  end

  def decrement_bookmark_count(bookmarkable)
    return unless bookmarkable.has_attribute?(:bookmarked_count)
    return if bookmarkable.bookmarked_count.to_i <= 0

    bookmarkable.decrement!(:bookmarked_count)
  end
end
