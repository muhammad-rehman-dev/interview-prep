class CreateBookmarks < ActiveRecord::Migration[7.2]
  def change
    create_table :bookmarks do |t|
      t.string :visitor_token
      t.string :bookmarkable_type
      t.integer :bookmarkable_id

      t.timestamps
    end
    add_index :bookmarks, :visitor_token
  end
end
