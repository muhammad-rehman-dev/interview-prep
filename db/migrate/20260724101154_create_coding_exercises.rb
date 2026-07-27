class CreateCodingExercises < ActiveRecord::Migration[7.2]
  def change
    create_table :coding_exercises do |t|
      t.string :title
      t.string :slug
      t.text :problem
      t.text :requirements
      t.text :expected_api
      t.text :hints
      t.text :step_by_step
      t.text :complete_solution
      t.text :best_practices
      t.string :time_complexity
      t.string :space_complexity
      t.text :senior_improvements
      t.text :follow_ups
      t.string :difficulty
      t.string :category
      t.integer :estimated_minutes
      t.integer :position

      t.timestamps
    end
    add_index :coding_exercises, :slug, unique: true
  end
end
