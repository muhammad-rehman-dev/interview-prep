class CreateCompanies < ActiveRecord::Migration[7.2]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :slug
      t.string :tagline
      t.text :description
      t.string :interview_focus
      t.string :website
      t.integer :position

      t.timestamps
    end
    add_index :companies, :slug, unique: true
  end
end
