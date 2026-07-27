class CreateQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :questions do |t|
      t.text :title
      t.text :body
      t.text :answer
      t.text :best_answer
      t.text :alternative_answer
      t.text :explanation
      t.text :common_mistakes
      t.text :follow_ups
      t.text :theory
      t.text :practical
      t.string :difficulty
      t.string :interview_type
      t.references :category, null: false, foreign_key: true
      t.string :company
      t.string :source
      t.string :tags_cache
      t.float :frequency_score
      t.integer :estimated_minutes
      t.float :confidence_score
      t.text :references_text
      t.text :related_slugs
      t.string :slug
      t.integer :bookmarked_count

      t.timestamps
    end
    add_index :questions, :slug, unique: true
  end
end
