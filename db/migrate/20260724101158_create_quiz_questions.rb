class CreateQuizQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :quiz_questions do |t|
      t.text :prompt
      t.text :options
      t.integer :correct_index
      t.text :explanation
      t.string :category
      t.string :difficulty

      t.timestamps
    end
  end
end
