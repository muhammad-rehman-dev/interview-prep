class CreateCheatsheetEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :cheatsheet_entries do |t|
      t.string :title
      t.string :slug
      t.text :rails_concept
      t.text :rails_explanation
      t.text :node_equivalent
      t.text :nest_equivalent
      t.text :rails_code
      t.text :node_code
      t.text :nest_code
      t.string :category
      t.integer :position

      t.timestamps
    end
    add_index :cheatsheet_entries, :slug, unique: true
  end
end
