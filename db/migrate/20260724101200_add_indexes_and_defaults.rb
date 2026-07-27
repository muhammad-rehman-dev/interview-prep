class AddIndexesAndDefaults < ActiveRecord::Migration[7.2]
  def change
    change_column_default :questions, :bookmarked_count, from: nil, to: 0
    change_column_default :questions, :frequency_score, from: nil, to: 0.5
    change_column_default :questions, :confidence_score, from: nil, to: 0.8
    change_column_default :questions, :estimated_minutes, from: nil, to: 5
    change_column_default :categories, :position, from: nil, to: 0
    change_column_default :categories, :target_count, from: nil, to: 50
    change_column_default :coding_exercises, :estimated_minutes, from: nil, to: 45
    change_column_default :mock_interviews, :duration_minutes, from: nil, to: 75

    add_index :questions, :difficulty
    add_index :questions, :interview_type
    add_index :questions, :company
    add_index :questions, :source
    add_index :questions, [:category_id, :difficulty]
    add_index :progress_records, [:visitor_token, :record_type, :record_id], unique: true, name: "idx_progress_unique"
    add_index :bookmarks, [:visitor_token, :bookmarkable_type, :bookmarkable_id], unique: true, name: "idx_bookmarks_unique"
    add_index :question_tags, [:question_id, :tag_id], unique: true
    add_index :coding_exercises, :difficulty
    add_index :coding_exercises, :category
    add_index :quiz_questions, :category
    add_index :cheatsheet_entries, :category
  end
end
