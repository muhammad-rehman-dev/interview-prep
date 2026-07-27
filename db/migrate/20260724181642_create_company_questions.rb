# frozen_string_literal: true

class CreateCompanyQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :company_questions do |t|
      t.references :company, null: false, foreign_key: true
      t.text :title
      t.string :slug
      t.text :body
      t.text :answer
      t.text :best_answer
      t.text :explanation
      t.text :common_mistakes
      t.text :follow_ups
      t.string :difficulty
      t.string :interview_round
      t.string :source
      t.string :tags_cache
      t.integer :estimated_minutes
      t.integer :position
      t.float :frequency_score

      t.timestamps
    end

    add_index :company_questions, [:company_id, :slug], unique: true
    add_index :company_questions, :difficulty
    add_index :company_questions, :interview_round
  end
end
