class CreateMockInterviewItems < ActiveRecord::Migration[7.2]
  def change
    create_table :mock_interview_items do |t|
      t.references :mock_interview, null: false, foreign_key: true
      t.string :section
      t.text :prompt
      t.text :expected_answer
      t.text :follow_ups
      t.integer :duration_minutes
      t.integer :position

      t.timestamps
    end
  end
end
