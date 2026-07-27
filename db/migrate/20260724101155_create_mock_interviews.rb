class CreateMockInterviews < ActiveRecord::Migration[7.2]
  def change
    create_table :mock_interviews do |t|
      t.string :title
      t.string :slug
      t.text :introduction
      t.integer :duration_minutes
      t.string :difficulty
      t.string :company_focus
      t.text :scoring_rubric
      t.text :interviewer_notes
      t.integer :position

      t.timestamps
    end
    add_index :mock_interviews, :slug, unique: true
  end
end
